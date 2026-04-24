// SciBridge.cpp
// Minimal C ABI bridge for statically linked Scintilla + Lexilla objects.
// Build this file with the same MSVC toolset and configuration as Scintilla/Lexilla.
// This file intentionally exposes only plain C symbols and opaque pointers.

#include <cstdint>
#include <windows.h>

// Upstream public headers.
#include "ILexer.h"
#include "Scintilla.h"
#include "Lexilla.h"

// Internal header for Scintilla_DirectFunction (static-link replacement for ScintillaDLL.cxx).
#include "ScintillaTypes.h"
#include "ScintillaWin.h"

extern "C" {

// Register the Scintilla window classes when Scintilla is linked statically.
// Scintilla's current Windows implementation exposes:
//   bool Scintilla_RegisterClasses(void *hInstance)
// and expects this to be called once.
__declspec(dllexport) bool __stdcall SciBridge_RegisterClasses(void *hInstance) {
    return Scintilla_RegisterClasses(hInstance) != 0;
}

// Optional symmetric cleanup.
__declspec(dllexport) bool __stdcall SciBridge_ReleaseResources() {
    return Scintilla_ReleaseResources() != 0;
}

// Create a lexer by name. The returned value is an ILexer5* but Delphi should
// treat it as an opaque pointer and pass it to SCI_SETILEXER.
__declspec(dllexport) void * __stdcall LexBridge_CreateLexer(const char *name) {
    return CreateLexer(name);
}

// Optional Lexilla initialization hook.
__declspec(dllexport) void __stdcall LexBridge_SetLibraryProperty(const char *key, const char *value) {
    SetLibraryProperty(key, value);
}

// Optional discovery hook.
__declspec(dllexport) const char * __stdcall LexBridge_GetLibraryPropertyNames() {
    return GetLibraryPropertyNames();
}

// Transitional helper only. Upstream documents this as deprecated.
__declspec(dllexport) const char * __stdcall LexBridge_LexerNameFromID(int identifier) {
    return LexerNameFromID(identifier);
}

// Optional namespace helper.
__declspec(dllexport) const char * __stdcall LexBridge_GetNameSpace() {
    return GetNameSpace();
}

// Convenience helper: directly assign a lexer created by name to a Scintilla window.
// Returns TRUE on success, FALSE if CreateLexer failed.
__declspec(dllexport) BOOL __stdcall LexBridge_AssignLexerByName(HWND hSci, const char *name) {
    void *pLexer = CreateLexer(name);
    if (!pLexer) {
        return FALSE;
    }
    ::SendMessage(hSci, SCI_SETILEXER, 0, reinterpret_cast<LPARAM>(pLexer));
    return TRUE;
}

// Direct-function bridge — replaces ScintillaDLL.cxx export for static linking.
__declspec(dllexport) Scintilla::sptr_t __stdcall Scintilla_DirectFunction(
    Scintilla::Internal::ScintillaWin *sci, UINT iMessage,
    Scintilla::uptr_t wParam, Scintilla::sptr_t lParam) {
    return Scintilla::Internal::DirectFunction(sci, iMessage, wParam, lParam);
}

}
