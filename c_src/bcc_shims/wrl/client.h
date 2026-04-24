// Minimal wrl/client.h shim for bcc64x (Embarcadero Clang)
// Provides Microsoft::WRL::ComPtr — a COM-aware smart pointer.
// Only the subset used by Scintilla is implemented.
#pragma once

#include <unknwn.h>

namespace Microsoft {
namespace WRL {

template <typename T> class ComPtr;

namespace Details {
template <typename T>
class ComPtrRef {
    ComPtr<T>* ptr_;
public:
    explicit ComPtrRef(ComPtr<T>* p) noexcept : ptr_(p) {}

    // For COM out-params (e.g. CreateSolidColorBrush(..., &brush))
    operator T**() noexcept { return ptr_->ReleaseAndGetAddressOf(); }
    operator void**() noexcept { return reinterpret_cast<void**>(ptr_->ReleaseAndGetAddressOf()); }

    // For .As(&target) template deduction
    operator ComPtr<T>*() noexcept { return ptr_; }
};
} // namespace Details

template <typename T>
class ComPtr {
    T* ptr_ = nullptr;

    void InternalAddRef() const noexcept {
        if (ptr_) ptr_->AddRef();
    }
    void InternalRelease() noexcept {
        T* temp = ptr_;
        if (temp) {
            ptr_ = nullptr;
            temp->Release();
        }
    }
public:
    ComPtr() noexcept = default;
    ComPtr(std::nullptr_t) noexcept : ptr_(nullptr) {}

    ComPtr(const ComPtr& other) noexcept : ptr_(other.ptr_) { InternalAddRef(); }

    template <typename U>
    ComPtr(const ComPtr<U>& other) noexcept : ptr_(other.Get()) { InternalAddRef(); }

    ComPtr(ComPtr&& other) noexcept : ptr_(other.ptr_) { other.ptr_ = nullptr; }

    ~ComPtr() noexcept { InternalRelease(); }

    ComPtr& operator=(std::nullptr_t) noexcept { InternalRelease(); return *this; }

    ComPtr& operator=(const ComPtr& other) noexcept {
        if (ptr_ != other.ptr_) { ComPtr(other).Swap(*this); }
        return *this;
    }

    template <typename U>
    ComPtr& operator=(const ComPtr<U>& other) noexcept {
        ComPtr(other).Swap(*this);
        return *this;
    }

    ComPtr& operator=(ComPtr&& other) noexcept {
        if (ptr_ != other.ptr_) { ComPtr(static_cast<ComPtr&&>(other)).Swap(*this); }
        return *this;
    }

    ComPtr& operator=(T* other) noexcept {
        if (ptr_ != other) {
            InternalRelease();
            ptr_ = other;
            InternalAddRef();
        }
        return *this;
    }

    void Swap(ComPtr& other) noexcept {
        T* tmp = ptr_;
        ptr_ = other.ptr_;
        other.ptr_ = tmp;
    }

    T* Get() const noexcept { return ptr_; }
    T* operator->() const noexcept { return ptr_; }
    Details::ComPtrRef<T> operator&() noexcept { return Details::ComPtrRef<T>(this); }

    T** GetAddressOf() noexcept { return &ptr_; }
    T* const* GetAddressOf() const noexcept { return &ptr_; }
    T** ReleaseAndGetAddressOf() noexcept { InternalRelease(); return &ptr_; }

    T* Detach() noexcept { T* p = ptr_; ptr_ = nullptr; return p; }

    void Attach(T* other) noexcept { InternalRelease(); ptr_ = other; }

    unsigned long Reset() noexcept { return InternalRelease(), 0; }

    operator bool() const noexcept { return ptr_ != nullptr; }

    template <typename U>
    HRESULT As(ComPtr<U>* p) const noexcept {
        return ptr_->QueryInterface(__uuidof(U), reinterpret_cast<void**>(p->ReleaseAndGetAddressOf()));
    }

    template <typename U>
    HRESULT As(Details::ComPtrRef<U> p) const noexcept {
        ComPtr<U>* target = static_cast<ComPtr<U>*>(p);
        return ptr_->QueryInterface(__uuidof(U), reinterpret_cast<void**>(target->ReleaseAndGetAddressOf()));
    }
};

} // namespace WRL
} // namespace Microsoft
