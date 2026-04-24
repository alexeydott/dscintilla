/*
 * SciBridge_CRT_x64.c — Win64 CRT Compatibility Shim
 *
 * Provides minimal C/C++ runtime function implementations for statically
 * linking MSVC-compiled Scintilla/Lexilla OBJ files with Delphi's dcc64.
 *
 * Compile:
 *   cl /c /O2 /Zl /GS- /Gs999999 /nologo SciBridge_CRT_x64.c /Fo<output>
 *
 * Design:
 *   - No CRT dependencies (compiled with /Zl to omit default-lib refs).
 *   - Does NOT include <windows.h> to avoid CRT inline function conflicts.
 *   - Manually declares needed Win32 API types and functions.
 *   - ASCII-only character classification (sufficient for Scintilla).
 *   - Minimal C++ exception stubs (terminate on throw).
 *   - Thread-safe static init via SRWLOCK/CONDITION_VARIABLE.
 */

/* ================================================================
 * Windows API declarations (replaces <windows.h> to avoid CRT
 * inline conflicts with memcpy, ceil, etc.)
 * ================================================================ */

/* Fundamental types (must precede Windows types) */
typedef unsigned __int64    size_t;
typedef __int64             ptrdiff_t;
typedef unsigned short      wchar_t;
typedef __int64             intptr_t;
typedef unsigned __int64    uintptr_t;

/* va_list — only needed as pass-through type, no va_start/va_arg needed */
typedef char *va_list;

typedef unsigned long       DWORD;
typedef unsigned long long  DWORD64;
typedef int                 BOOL;
typedef int                 INT;
typedef unsigned int        UINT;
typedef long                LONG;
typedef unsigned long       ULONG;
typedef unsigned short      WORD;
typedef unsigned char       BYTE;
typedef void               *HANDLE;
typedef void               *HMODULE;
typedef void               *PVOID;
typedef HANDLE              HINSTANCE;
typedef DWORD              *LPDWORD;
typedef char               *LPSTR;
typedef const char         *LPCSTR;
typedef wchar_t            *LPWSTR;
typedef const wchar_t      *LPCWSTR;
typedef __int64             LONGLONG;
typedef unsigned __int64    ULONGLONG;
typedef int (__stdcall *FARPROC)(void);

#ifndef NULL
#define NULL ((void*)0)
#endif
#define INFINITE       0xFFFFFFFF
#define HEAP_ZERO_MEMORY 0x00000008

typedef union _LARGE_INTEGER {
    struct { DWORD LowPart; LONG HighPart; };
    LONGLONG QuadPart;
} LARGE_INTEGER;

typedef union _ULARGE_INTEGER {
    struct { DWORD LowPart; DWORD HighPart; };
    ULONGLONG QuadPart;
} ULARGE_INTEGER;

typedef struct _FILETIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
} FILETIME;

typedef struct _SYSTEM_INFO {
    union { DWORD dwOemId; struct { WORD wProcessorArchitecture; WORD wReserved; }; };
    DWORD dwPageSize;
    void *lpMinimumApplicationAddress;
    void *lpMaximumApplicationAddress;
    DWORD64 dwActiveProcessorMask;
    DWORD dwNumberOfProcessors;
    DWORD dwProcessorType;
    DWORD dwAllocationGranularity;
    WORD wProcessorLevel;
    WORD wProcessorRevision;
} SYSTEM_INFO;

/* SRWLOCK / CONDITION_VARIABLE — opaque pointer-sized values. */
typedef struct { void *Ptr; } SRWLOCK, *PSRWLOCK;
typedef struct { void *Ptr; } CONDITION_VARIABLE, *PCONDITION_VARIABLE;
#define SRWLOCK_INIT {0}
#define CONDITION_VARIABLE_INIT {0}

/* Kernel32 imports */
__declspec(dllimport) HANDLE  __stdcall GetProcessHeap(void);
__declspec(dllimport) void   *__stdcall HeapAlloc(HANDLE, DWORD, size_t);
__declspec(dllimport) BOOL    __stdcall HeapFree(HANDLE, DWORD, void *);
__declspec(dllimport) void   *__stdcall HeapReAlloc(HANDLE, DWORD, void *, size_t);
__declspec(dllimport) HANDLE  __stdcall GetCurrentProcess(void);
__declspec(dllimport) BOOL    __stdcall TerminateProcess(HANDLE, UINT);
__declspec(dllimport) DWORD   __stdcall GetCurrentThreadId(void);
__declspec(dllimport) BOOL    __stdcall QueryPerformanceCounter(LARGE_INTEGER *);
__declspec(dllimport) BOOL    __stdcall QueryPerformanceFrequency(LARGE_INTEGER *);
__declspec(dllimport) void    __stdcall GetSystemInfo(SYSTEM_INFO *);
__declspec(dllimport) void    __stdcall GetSystemTimeAsFileTime(FILETIME *);
__declspec(dllimport) HMODULE __stdcall LoadLibraryA(LPCSTR);
__declspec(dllimport) HMODULE __stdcall GetModuleHandleA(LPCSTR);
__declspec(dllimport) FARPROC __stdcall GetProcAddress(HMODULE, LPCSTR);
__declspec(dllimport) DWORD   __stdcall GetLastError(void);

/* SRWLOCK */
__declspec(dllimport) void __stdcall InitializeSRWLock(PSRWLOCK);
__declspec(dllimport) void __stdcall AcquireSRWLockExclusive(PSRWLOCK);
__declspec(dllimport) void __stdcall ReleaseSRWLockExclusive(PSRWLOCK);
__declspec(dllimport) BOOL __stdcall TryAcquireSRWLockExclusive(PSRWLOCK);

/* CONDITION_VARIABLE */
__declspec(dllimport) void __stdcall InitializeConditionVariable(PCONDITION_VARIABLE);
__declspec(dllimport) BOOL __stdcall SleepConditionVariableSRW(PCONDITION_VARIABLE, PSRWLOCK, DWORD, ULONG);
__declspec(dllimport) void __stdcall WakeConditionVariable(PCONDITION_VARIABLE);
__declspec(dllimport) void __stdcall WakeAllConditionVariable(PCONDITION_VARIABLE);


#ifdef __cplusplus
extern "C" {
#endif

/* ================================================================
 * SECTION 1: MSVC Compiler-Support Variables & Stubs
 * ================================================================ */

/* Linker flag: indicates floating-point usage. */
int _fltused = 0x9875;

/* Thread-local-storage index (static link → slot 0). */
unsigned long _tls_index = 0;

/* Security cookie (not used with /GS-, kept as safety net). */
unsigned __int64 __security_cookie = 0x00002B992DDFA232ULL;

void __security_check_cookie(unsigned __int64 val)
{
    if (val != __security_cookie)
        TerminateProcess(GetCurrentProcess(), 3);
}

void _purecall(void)
{
    TerminateProcess(GetCurrentProcess(), 1);
}

void _invalid_parameter_noinfo_noreturn(void)
{
    TerminateProcess(GetCurrentProcess(), 1);
}

void __report_rangecheckfailure(void)
{
    TerminateProcess(GetCurrentProcess(), 1);
}

/* ================================================================
 * SECTION 2: Math Functions
 *
 * Integer-cast approach avoids SSE4.1 dependency. Safe for all
 * values within int64 range (covers all practical Scintilla usage).
 * ================================================================ */

double ceil(double x)
{
    if (x != x) return x;                  /* NaN passthrough */
    long long i = (long long)x;
    double d = (double)i;
    if (x > 0.0 && d < x) return d + 1.0;
    return d;
}

float ceilf(float x)
{
    if (x != x) return x;
    long long i = (long long)x;
    float d = (float)i;
    if (x > 0.0f && d < x) return d + 1.0f;
    return d;
}

double floor(double x)
{
    if (x != x) return x;
    long long i = (long long)x;
    double d = (double)i;
    if (x < 0.0 && d > x) return d - 1.0;
    return d;
}

float floorf(float x)
{
    if (x != x) return x;
    long long i = (long long)x;
    float d = (float)i;
    if (x < 0.0f && d > x) return d - 1.0f;
    return d;
}

double trunc(double x)
{
    if (x != x) return x;
    return (double)(long long)x;
}

float truncf(float x)
{
    if (x != x) return x;
    return (float)(long long)x;
}

/* Only _dsci_* versions are provided here.The rename_coff_symbols.py script
   renames all "round"/"lround"/etc. references in extracted OBJ files to
   _dsci_round/_dsci_lround so these definitions satisfy the renamed refs.
   Providing separate round()/lround() definitions would create duplicate
   symbols after the rename script processes this OBJ. */

double _dsci_round(double x)
{
    if (x != x) return x;
    if (x >= 0.0) return floor(x + 0.5);
    return ceil(x - 0.5);
}

float _dsci_roundf(float x)
{
    if (x != x) return x;
    if (x >= 0.0f) return floorf(x + 0.5f);
    return ceilf(x - 0.5f);
}

long _dsci_lround(double x)  { return (long)_dsci_round(x); }
long _dsci_lroundf(float x)  { return (long)_dsci_roundf(x); }

double _dsci_trunc(double x)
{
    /* Truncate toward zero — cast to long long and back. */
    if (x >= 0.0) {
        long long i = (long long)x;
        return (double)i;
    } else {
        long long i = (long long)(-x);
        return -(double)i;
    }
}
float _dsci_truncf(float x)  { return (float)_dsci_trunc((double)x); }

double log2(double x)
{
    /* log2(x) = ln(x) / ln(2).  Minimal bit-hack for positive values. */
    /* Full precision not required — Scintilla uses this rarely. */
    if (x <= 0.0) {
        union { unsigned __int64 u; double d; } neg_inf;
        neg_inf.u = 0xFFF0000000000000ULL;
        return neg_inf.d; /* -inf */
    }

    /* Use change-of-base via natural log approximation. */
    /* Extract exponent and mantissa from IEEE 754. */
    union { double d; unsigned __int64 u; } cvt;
    cvt.d = x;
    int exp = (int)((cvt.u >> 52) & 0x7FF) - 1023;
    cvt.u = (cvt.u & 0x000FFFFFFFFFFFFFULL) | 0x3FF0000000000000ULL;
    double m = cvt.d; /* mantissa in [1,2) */

    /* Minimax polynomial for log2(m) over [1,2) */
    double a = m - 1.0;
    double log2m = a * (1.4426950408889634 - a * (0.7213475204444817
                    - a * (0.4808983469629878 - a * 0.3606737602222409)));
    return (double)exp + log2m;
}

/* ================================================================
 * SECTION 3: Memory Functions
 *
 * Optimizations OFF to prevent the compiler from recognizing these
 * loops as memcpy/memset patterns and replacing them with calls
 * to themselves (infinite recursion).
 * ================================================================ */

#pragma optimize("", off)

void *memcpy(void *dst, const void *src, size_t n)
{
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    while (n--) *d++ = *s++;
    return dst;
}

void *memmove(void *dst, const void *src, size_t n)
{
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    if (d < s) {
        while (n--) *d++ = *s++;
    } else if (d > s) {
        d += n; s += n;
        while (n--) *--d = *--s;
    }
    return dst;
}

void *memset(void *dst, int c, size_t n)
{
    unsigned char *d = (unsigned char *)dst;
    while (n--) *d++ = (unsigned char)c;
    return dst;
}

int memcmp(const void *s1, const void *s2, size_t n)
{
    const unsigned char *a = (const unsigned char *)s1;
    const unsigned char *b = (const unsigned char *)s2;
    while (n--) {
        if (*a != *b) return (int)*a - (int)*b;
        a++; b++;
    }
    return 0;
}

void *memchr(const void *s, int c, size_t n)
{
    const unsigned char *p = (const unsigned char *)s;
    while (n--) {
        if (*p == (unsigned char)c) return (void *)p;
        p++;
    }
    return 0;
}

#pragma optimize("", on)

/* ================================================================
 * SECTION 4: String Functions
 * ================================================================ */

#pragma optimize("", off)

size_t strlen(const char *s)
{
    const char *p = s;
    while (*p) p++;
    return (size_t)(p - s);
}

size_t wcslen(const wchar_t *s)
{
    const wchar_t *p = s;
    while (*p) p++;
    return (size_t)(p - s);
}

char *strchr(const char *s, int c)
{
    for (;; s++) {
        if (*s == (char)c) return (char *)s;
        if (*s == '\0') return 0;
    }
}

int strcmp(const char *s1, const char *s2)
{
    while (*s1 && *s1 == *s2) { s1++; s2++; }
    return (unsigned char)*s1 - (unsigned char)*s2;
}

int strncmp(const char *s1, const char *s2, size_t n)
{
    if (!n) return 0;
    while (--n && *s1 && *s1 == *s2) { s1++; s2++; }
    return (unsigned char)*s1 - (unsigned char)*s2;
}

char *strncpy(char *dst, const char *src, size_t n)
{
    char *d = dst;
    while (n && (*d = *src)) { d++; src++; n--; }
    while (n--) *d++ = '\0';
    return dst;
}

size_t strnlen(const char *s, size_t maxlen)
{
    size_t n = 0;
    while (n < maxlen && s[n]) n++;
    return n;
}

char *strstr(const char *haystack, const char *needle)
{
    if (!*needle) return (char *)haystack;
    for (; *haystack; haystack++) {
        const char *h = haystack, *n = needle;
        while (*h && *n && *h == *n) { h++; n++; }
        if (!*n) return (char *)haystack;
    }
    return 0;
}

char *strrchr(const char *s, int c)
{
    const char *last = 0;
    for (;; s++) {
        if (*s == (char)c) last = s;
        if (*s == '\0') return (char *)last;
    }
}

size_t strspn(const char *s, const char *accept)
{
    const char *p = s;
    while (*p) {
        const char *a = accept;
        int found = 0;
        while (*a) { if (*a++ == *p) { found = 1; break; } }
        if (!found) break;
        p++;
    }
    return (size_t)(p - s);
}

int wcscmp(const wchar_t *s1, const wchar_t *s2)
{
    while (*s1 && *s1 == *s2) { s1++; s2++; }
    return (int)*s1 - (int)*s2;
}

#pragma optimize("", on)

/* ================================================================
 * SECTION 5: Character Classification (ASCII)
 * ================================================================ */

int isalnum(int c)  { return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9'); }
int isalpha(int c)  { return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'); }
int isdigit(int c)  { return c >= '0' && c <= '9'; }
int islower(int c)  { return c >= 'a' && c <= 'z'; }
int isupper(int c)  { return c >= 'A' && c <= 'Z'; }
int isxdigit(int c) { return (c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f'); }
int isspace(int c)  { return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\f' || c == '\v'; }
int isprint(int c)  { return c >= 0x20 && c <= 0x7E; }
int iscntrl(int c)  { return (c >= 0 && c < 0x20) || c == 0x7F; }
int isgraph(int c)  { return c > 0x20 && c <= 0x7E; }
int ispunct(int c)  { return isgraph(c) && !isalnum(c); }
int tolower(int c)  { return isupper(c) ? c + ('a' - 'A') : c; }
int toupper(int c)  { return islower(c) ? c - ('a' - 'A') : c; }

/* ================================================================
 * SECTION 6: Heap-Based Memory Management
 * ================================================================ */

static HANDLE _crt_heap;

static __forceinline HANDLE _get_heap(void)
{
    HANDLE h = _crt_heap;
    if (!h) { h = GetProcessHeap(); _crt_heap = h; }
    return h;
}

void *malloc(size_t size)
{
    if (!size) size = 1;
    return HeapAlloc(_get_heap(), 0, size);
}

void free(void *ptr)
{
    if (ptr) HeapFree(_get_heap(), 0, ptr);
}

void *realloc(void *ptr, size_t size)
{
    if (!ptr) return malloc(size);
    if (!size) { free(ptr); return 0; }
    return HeapReAlloc(_get_heap(), 0, ptr, size);
}

void *calloc(size_t count, size_t size)
{
    size_t total = count * size;
    if (!total) total = 1;
    return HeapAlloc(_get_heap(), HEAP_ZERO_MEMORY, total);
}

/* operator new / operator delete for C++ objects in the linked OBJs. */
void *_malloc_crt(size_t size) { return malloc(size); }

/* ================================================================
 * SECTION 7: Miscellaneous C Functions
 * ================================================================ */

void abort(void)
{
    TerminateProcess(GetCurrentProcess(), 3);
}

static void (*_atexit_funcs[64])(void);
static int _atexit_count;

int atexit(void (*func)(void))
{
    if (_atexit_count >= 64) return 1;
    _atexit_funcs[_atexit_count++] = func;
    return 0;
}

int atoi(const char *s)
{
    int result = 0, sign = 1;
    while (*s == ' ' || *s == '\t') s++;
    if (*s == '-') { sign = -1; s++; }
    else if (*s == '+') s++;
    while (*s >= '0' && *s <= '9')
        result = result * 10 + (*s++ - '0');
    return result * sign;
}

long strtol(const char *s, char **endptr, int base)
{
    long result = 0, sign = 1;
    while (*s == ' ' || *s == '\t') s++;
    if (*s == '-') { sign = -1; s++; }
    else if (*s == '+') s++;
    if (base == 0) {
        if (*s == '0' && (s[1] == 'x' || s[1] == 'X')) { base = 16; s += 2; }
        else if (*s == '0') { base = 8; s++; }
        else base = 10;
    } else if (base == 16 && *s == '0' && (s[1] == 'x' || s[1] == 'X')) {
        s += 2;
    }
    while (*s) {
        int d;
        if (*s >= '0' && *s <= '9') d = *s - '0';
        else if (*s >= 'a' && *s <= 'z') d = *s - 'a' + 10;
        else if (*s >= 'A' && *s <= 'Z') d = *s - 'A' + 10;
        else break;
        if (d >= base) break;
        result = result * base + d;
        s++;
    }
    if (endptr) *endptr = (char *)s;
    return result * sign;
}

unsigned long strtoul(const char *s, char **endptr, int base)
{
    return (unsigned long)strtol(s, endptr, base);
}

/* ================================================================
 * SECTION 8: Formatted I/O (forwarded to ntdll)
 * ================================================================ */

typedef int (__cdecl *fn_vsnprintf_t)(char *, size_t, const char *, va_list);
typedef int (__cdecl *fn_vsnwprintf_t)(wchar_t *, size_t, const wchar_t *, va_list);
static fn_vsnprintf_t  pfn_vsnprintf;
static fn_vsnwprintf_t pfn_vsnwprintf;

static void _init_ntdll_io(void)
{
    HMODULE ntdll = GetModuleHandleA("ntdll.dll");
    if (ntdll) {
        pfn_vsnprintf  = (fn_vsnprintf_t)GetProcAddress(ntdll, "_vsnprintf");
        pfn_vsnwprintf = (fn_vsnwprintf_t)GetProcAddress(ntdll, "_vsnwprintf");
    }
}

int __cdecl __stdio_common_vsprintf(
    unsigned __int64 options, char *buffer, size_t bufferCount,
    const char *format, void *locale, va_list argptr)
{
    (void)options; (void)locale;
    if (!pfn_vsnprintf) _init_ntdll_io();
    if (pfn_vsnprintf && buffer && bufferCount)
        return pfn_vsnprintf(buffer, bufferCount, format, argptr);
    return -1;
}

int __cdecl __stdio_common_vsprintf_s(
    unsigned __int64 options, char *buffer, size_t bufferCount,
    const char *format, void *locale, va_list argptr)
{
    return __stdio_common_vsprintf(options, buffer, bufferCount, format, locale, argptr);
}

int __cdecl __stdio_common_vswprintf(
    unsigned __int64 options, wchar_t *buffer, size_t bufferCount,
    const wchar_t *format, void *locale, va_list argptr)
{
    (void)options; (void)locale;
    if (!pfn_vsnwprintf) _init_ntdll_io();
    if (pfn_vsnwprintf && buffer && bufferCount)
        return pfn_vsnwprintf(buffer, bufferCount, format, argptr);
    return -1;
}

int __cdecl __stdio_common_vsscanf(
    unsigned __int64 options, const char *buffer, size_t bufferCount,
    const char *format, void *locale, va_list argptr)
{
    (void)options; (void)bufferCount; (void)locale;
    (void)buffer; (void)format; (void)argptr;
    /* Scintilla rarely uses sscanf; return 0 (no matches). */
    return 0;
}

/* ================================================================
 * SECTION 9: C++ Exception Handling Stubs
 *
 * Scintilla should never throw across its C-ABI boundary.  These
 * stubs terminate the process if a C++ exception is actually raised.
 * ================================================================ */

/* SEH personality routine for /EHsc frames. */
int __CxxFrameHandler4(
    void *ExceptionRecord, void *EstablisherFrame,
    void *ContextRecord, void *DispatcherContext)
{
    (void)ExceptionRecord; (void)EstablisherFrame;
    (void)ContextRecord; (void)DispatcherContext;
    return 1; /* ExceptionContinueSearch */
}

/* Older EH handler version (safety net). */
int __CxxFrameHandler3(
    void *ExceptionRecord, void *EstablisherFrame,
    void *ContextRecord, void *DispatcherContext)
{
    (void)ExceptionRecord; (void)EstablisherFrame;
    (void)ContextRecord; (void)DispatcherContext;
    return 1;
}

/* GS+EH combined handlers (safety net for /GS-). */
int __GSHandlerCheck(
    void *ExceptionRecord, void *EstablisherFrame,
    void *ContextRecord, void *DispatcherContext)
{
    (void)ExceptionRecord; (void)EstablisherFrame;
    (void)ContextRecord; (void)DispatcherContext;
    return 1;
}

int __GSHandlerCheck_EH4(
    void *ExceptionRecord, void *EstablisherFrame,
    void *ContextRecord, void *DispatcherContext)
{
    (void)ExceptionRecord; (void)EstablisherFrame;
    (void)ContextRecord; (void)DispatcherContext;
    return 1;
}

__declspec(noreturn) void _CxxThrowException(void *pObject, void *pThrowInfo)
{
    (void)pObject; (void)pThrowInfo;
    TerminateProcess(GetCurrentProcess(), 1);
}

void __std_terminate(void) { TerminateProcess(GetCurrentProcess(), 1); }
void terminate(void)       { TerminateProcess(GetCurrentProcess(), 1); }

/* std::exception copy/destroy helpers. */
void __std_exception_copy(const void *src, void *dst)
{
    /* Layout: { const char *_What; int _DoFree; } */
    const char **s = (const char **)src;
    char **d = (char **)dst;
    d[0] = (char *)s[0];  /* shallow copy of what() pointer */
    ((int *)dst)[2] = 0;  /* _DoFree = false */
}

void __std_exception_destroy(void *p)
{
    char **pp = (char **)p;
    if (((int *)p)[2]) { /* _DoFree */
        free(pp[0]);
        pp[0] = 0;
    }
}

/* ================================================================
 * SECTION 10: RTTI Stub
 * ================================================================ */

void *__RTDynamicCast(
    void *inptr, long VfDelta, void *SrcType,
    void *TargetType, int isReference)
{
    (void)VfDelta; (void)SrcType; (void)TargetType;
    /* Scintilla uses dynamic_cast for known-valid hierarchy casts.
       Return the pointer as-is; the cast is always valid in practice. */
    if (isReference && !inptr)
        TerminateProcess(GetCurrentProcess(), 1);
    return inptr;
}

/* ================================================================
 * SECTION 11: Thread-Safe Static Initialisation (Magic Statics)
 * ================================================================ */

static SRWLOCK _init_lock  = SRWLOCK_INIT;
static CONDITION_VARIABLE _init_cv = CONDITION_VARIABLE_INIT;

long _Init_thread_epoch = -1;

void __cdecl _Init_thread_header(int *pOnce)
{
    AcquireSRWLockExclusive(&_init_lock);
    if (*pOnce == -1) {
        *pOnce = -2;   /* mark "being initialised" */
    } else {
        while (*pOnce == -2)
            SleepConditionVariableSRW(&_init_cv, &_init_lock, INFINITE, 0);
    }
    ReleaseSRWLockExclusive(&_init_lock);
}

void __cdecl _Init_thread_footer(int *pOnce)
{
    AcquireSRWLockExclusive(&_init_lock);
    ++_Init_thread_epoch;
    *pOnce = _Init_thread_epoch;
    ReleaseSRWLockExclusive(&_init_lock);
    WakeAllConditionVariable(&_init_cv);
}

void __cdecl _Init_thread_abort(int *pOnce)
{
    AcquireSRWLockExclusive(&_init_lock);
    *pOnce = -1;
    ReleaseSRWLockExclusive(&_init_lock);
    WakeAllConditionVariable(&_init_cv);
}

/* ================================================================
 * SECTION 12: STL Mutex & Condition Variable
 *
 * _Mtx_* / _Cnd_* are thin wrappers around Windows SRWLOCK /
 * CONDITION_VARIABLE, stored in-situ at the address provided
 * by the STL code.
 * ================================================================ */

/* Internal layout mirroring MSVC's _Mtx_internal_imp_t (24 bytes). */
typedef struct {
    int   type;     /* 0=plain, 4=recursive, etc.  */
    int   count;    /* recursion count              */
    SRWLOCK srw;    /* 8 bytes                      */
    DWORD owner;    /* owning thread id             */
    int   pad;
} MtxImpl;

void __cdecl _Mtx_init_in_situ(void *mtx, int type)
{
    MtxImpl *m = (MtxImpl *)mtx;
    memset(m, 0, sizeof(*m));
    m->type = type;
    InitializeSRWLock(&m->srw);
}

void __cdecl _Mtx_destroy_in_situ(void *mtx) { (void)mtx; }

int __cdecl _Mtx_lock(void *mtx)
{
    MtxImpl *m = (MtxImpl *)mtx;
    if (m->type & 4) { /* recursive */
        DWORD tid = GetCurrentThreadId();
        if (m->owner == tid) { m->count++; return 0; }
        AcquireSRWLockExclusive(&m->srw);
        m->owner = tid;
        m->count = 1;
    } else {
        AcquireSRWLockExclusive(&m->srw);
    }
    return 0;
}

int __cdecl _Mtx_unlock(void *mtx)
{
    MtxImpl *m = (MtxImpl *)mtx;
    if (m->type & 4) {
        if (--m->count == 0) {
            m->owner = 0;
            ReleaseSRWLockExclusive(&m->srw);
        }
    } else {
        ReleaseSRWLockExclusive(&m->srw);
    }
    return 0;
}

int __cdecl _Mtx_trylock(void *mtx)
{
    MtxImpl *m = (MtxImpl *)mtx;
    if (m->type & 4) {
        DWORD tid = GetCurrentThreadId();
        if (m->owner == tid) { m->count++; return 0; }
        if (!TryAcquireSRWLockExclusive(&m->srw)) return 1; /* _Thrd_busy */
        m->owner = tid;
        m->count = 1;
        return 0;
    }
    return TryAcquireSRWLockExclusive(&m->srw) ? 0 : 1;
}

/* Condition variable — stored as a plain CONDITION_VARIABLE (8 bytes). */

void __cdecl _Cnd_init_in_situ(void *cnd)
{
    InitializeConditionVariable((CONDITION_VARIABLE *)cnd);
}

void __cdecl _Cnd_destroy_in_situ(void *cnd) { (void)cnd; }

int __cdecl _Cnd_wait(void *cnd, void *mtx)
{
    MtxImpl *m = (MtxImpl *)mtx;
    SleepConditionVariableSRW((CONDITION_VARIABLE *)cnd, &m->srw, INFINITE, 0);
    return 0;
}

int __cdecl _Cnd_timedwait(void *cnd, void *mtx, const void *target)
{
    /* target is struct xtime { long long sec; long nsec; } */
    const long long *xt = (const long long *)target;
    long long target_sec = xt[0];
    long target_nsec = ((const long *)target)[2];

    FILETIME ft;
    GetSystemTimeAsFileTime(&ft);
    ULARGE_INTEGER now;
    now.LowPart  = ft.dwLowDateTime;
    now.HighPart = ft.dwHighDateTime;

    long long now_100ns = (long long)now.QuadPart - 116444736000000000LL;
    long long target_100ns = target_sec * 10000000LL + target_nsec / 100;
    long long diff_ms = (target_100ns - now_100ns) / 10000;

    if (diff_ms <= 0) return 2; /* _Thrd_timedout */

    MtxImpl *m = (MtxImpl *)mtx;
    DWORD ms = (diff_ms > 0xFFFFFFFF) ? INFINITE : (DWORD)diff_ms;
    if (!SleepConditionVariableSRW((CONDITION_VARIABLE *)cnd, &m->srw, ms, 0))
        return 2;
    return 0;
}

int __cdecl _Cnd_broadcast(void *cnd)
{
    WakeAllConditionVariable((CONDITION_VARIABLE *)cnd);
    return 0;
}

int __cdecl _Cnd_signal(void *cnd)
{
    WakeConditionVariable((CONDITION_VARIABLE *)cnd);
    return 0;
}

/* ================================================================
 * SECTION 13: Performance Counters & Threading Helpers
 * ================================================================ */

long long _Query_perf_counter(void)
{
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    return li.QuadPart;
}

long long _Query_perf_frequency(void)
{
    LARGE_INTEGER li;
    QueryPerformanceFrequency(&li);
    return li.QuadPart;
}

unsigned int _Thrd_hardware_concurrency(void)
{
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    return si.dwNumberOfProcessors;
}

/* ================================================================
 * SECTION 14: Locale Stubs (Minimal "C" Locale)
 * ================================================================ */

/* Collation vector (returned by value, 8 bytes on x64). */
typedef struct { unsigned long hand; unsigned int page; } CollVec;
/* Ctype vector (returned via hidden ptr, >8 bytes). */
typedef struct { unsigned long hand; unsigned int page; const short *table; int delfl; } CtypeVec;
/* Codecvt vector (8 bytes). */
typedef struct { unsigned long hand; unsigned int page; } CvtVec;

CollVec __cdecl _Getcoll(void)
{
    CollVec v = { 0, 0 };
    return v;
}

CtypeVec __cdecl _Getctype(void)
{
    CtypeVec v = { 0, 0, 0, 0 };
    return v;
}

CvtVec __cdecl _Getcvt(void)
{
    CvtVec v = { 0, 0 };
    return v;
}

short __cdecl _Getwctype(wchar_t c, const void *cvec)
{
    (void)cvec;
    short r = 0;
    if (c >= L'A' && c <= L'Z') r |= 0x0001; /* _UPPER */
    if (c >= L'a' && c <= L'z') r |= 0x0002; /* _LOWER */
    if (c >= L'0' && c <= L'9') r |= 0x0004; /* _DIGIT */
    if (c == L' ' || (c >= L'\t' && c <= L'\r')) r |= 0x0008; /* _SPACE */
    if (c >= 0x20 && c <= 0x7E && !((r & 0x0007) || c == L' ')) r |= 0x0010; /* _PUNCT */
    if ((c >= 0 && c < 0x20) || c == 0x7F) r |= 0x0020; /* _CONTROL */
    if (c >= 0x20 && c <= 0x7E) r |= 0x0100; /* _PRINT (non-standard position) */
    return r;
}

const short *__cdecl _Getwctypes(
    const wchar_t *first, const wchar_t *last, short *dest, const void *cvec)
{
    while (first < last)
        *dest++ = _Getwctype(*first++, cvec);
    return dest;
}

int __cdecl _Mbrtowc(wchar_t *pwc, const char *s, size_t n,
                     void *mbst, const void *cvec)
{
    (void)mbst; (void)cvec;
    if (!s) return 0;
    if (!n) return -2;
    if (pwc) *pwc = (wchar_t)(unsigned char)*s;
    return *s ? 1 : 0;
}

int __cdecl _Wcrtomb(char *s, wchar_t wc, void *mbst, const void *cvec)
{
    (void)mbst; (void)cvec;
    if (s) *s = (char)(unsigned char)wc;
    return 1;
}

int __cdecl _Strcoll(const char *s1, const char *e1,
                     const char *s2, const char *e2, const void *cvec)
{
    (void)cvec;
    size_t n1 = (size_t)(e1 - s1), n2 = (size_t)(e2 - s2);
    size_t n = (n1 < n2) ? n1 : n2;
    int r = memcmp(s1, s2, n);
    if (r) return r;
    return (n1 < n2) ? -1 : (n1 > n2) ? 1 : 0;
}

size_t __cdecl _Strxfrm(char *dst, char *dstend,
                        const char *src, const char *srcend, const void *cvec)
{
    (void)cvec;
    size_t len = (size_t)(srcend - src);
    size_t cap = (size_t)(dstend - dst);
    if (cap > 0) {
        size_t copy = (len < cap) ? len : cap - 1;
        memcpy(dst, src, copy);
        dst[copy] = '\0';
    }
    return len;
}

int __cdecl _Wcscoll(const wchar_t *s1, const wchar_t *e1,
                     const wchar_t *s2, const wchar_t *e2, const void *cvec)
{
    (void)cvec;
    size_t n1 = (size_t)(e1 - s1), n2 = (size_t)(e2 - s2);
    size_t n = (n1 < n2) ? n1 : n2;
    for (size_t i = 0; i < n; i++) {
        if (s1[i] != s2[i]) return (int)s1[i] - (int)s2[i];
    }
    return (n1 < n2) ? -1 : (n1 > n2) ? 1 : 0;
}

size_t __cdecl _Wcsxfrm(wchar_t *dst, wchar_t *dstend,
                        const wchar_t *src, const wchar_t *srcend, const void *cvec)
{
    (void)cvec;
    size_t len = (size_t)(srcend - src);
    size_t cap = (size_t)(dstend - dst);
    if (cap > 0) {
        size_t copy = (len < cap) ? len : cap - 1;
        for (size_t i = 0; i < copy; i++) dst[i] = src[i];
        dst[copy] = L'\0';
    }
    return len;
}

int __cdecl _Tolower(int c, const void *cvec)  { (void)cvec; return tolower(c); }
int __cdecl _Toupper(int c, const void *cvec)  { (void)cvec; return toupper(c); }
unsigned short __cdecl _Towlower(unsigned short c, const void *cvec)
{
    (void)cvec;
    return (c >= L'A' && c <= L'Z') ? c + (L'a' - L'A') : c;
}
unsigned short __cdecl _Towupper(unsigned short c, const void *cvec)
{
    (void)cvec;
    return (c >= L'a' && c <= L'z') ? c - (L'a' - L'A') : c;
}

/* ================================================================
 * SECTION 15: COM Interface IIDs
 * ================================================================ */

/* DEFINE_GUID workaround — define as plain structs. */
typedef struct { unsigned long Data1; unsigned short Data2, Data3; unsigned char Data4[8]; } SCIID;

const SCIID IID_IUnknown        = {0x00000000,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SCIID IID_IDataObject     = {0x0000010E,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SCIID IID_IDropSource     = {0x00000121,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SCIID IID_IDropTarget     = {0x00000122,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SCIID IID_IEnumFORMATETC  = {0x00000103,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};

/* ================================================================
 * SECTION 16: C++ new/delete Operators
 *
 * MSVC C++ OBJ files reference these for heap allocation.
 * Symbols: ??2@YAPEAX_K@Z (op new) / ??3@YAXPEAX@Z (op delete)
 * On x64 they are C-name mangled; we use pragmas to alias.
 * ================================================================ */

/* These are only reachable if compiled as C++ .  For a C file the
   mangled names are emitted by the Scintilla/Lexilla objects and
   the Delphi linker resolves them directly from the COFF symbol
   table.  We cannot define mangled-name symbols from C; instead
   we rely on the Scintilla OBJ files linking against each other
   (they carry their own operator new/delete in the static-MT CRT
   objects that were already extracted).  If still unresolved the
   linker will find malloc/free above. */

/* ================================================================
 * SECTION 17: IMM32 Import Thunks
 *
 * Scintilla includes <imm.h> and references ImmXxx functions via
 * __imp_ImmXxx (DLL import) symbols.  Delphi's linker may not
 * provide these.  We offer dynamic-load thunks as a fallback.
 * ================================================================ */

static HMODULE _imm32;

static FARPROC _imm_proc(const char *name)
{
    if (!_imm32) _imm32 = LoadLibraryA("imm32.dll");
    return _imm32 ? GetProcAddress(_imm32, name) : 0;
}

#define IMM_THUNK(ret, name, params, args) \
    ret __stdcall name params {            \
        typedef ret (__stdcall *PFN) params;\
        static PFN pfn;                    \
        if (!pfn) pfn = (PFN)_imm_proc(#name);\
        if (pfn) return pfn args;          \
        return (ret)0;                     \
    }

/* Only needed if the linker can't resolve __imp_Imm* from Delphi.
   These are guarded by the linker — if __imp_ImmGetContext is
   already resolved, these definitions won't conflict. */

/* (Uncomment if needed after first link attempt.)
IMM_THUNK(HIMC, ImmGetContext, (HWND w), (w))
IMM_THUNK(BOOL, ImmReleaseContext, (HWND w, HIMC h), (w, h))
IMM_THUNK(LONG, ImmGetCompositionStringW, (HIMC h, DWORD i, void *b, DWORD l), (h,i,b,l))
IMM_THUNK(BOOL, ImmSetCompositionFontW, (HIMC h, void *lf), (h, lf))
IMM_THUNK(BOOL, ImmSetCompositionWindow, (HIMC h, void *cf), (h, cf))
IMM_THUNK(BOOL, ImmSetCandidateWindow, (HIMC h, void *cf), (h, cf))
IMM_THUNK(BOOL, ImmNotifyIME, (HIMC h, DWORD a, DWORD i, DWORD v), (h,a,i,v))
IMM_THUNK(LRESULT, ImmEscapeW, (HKL hkl, HIMC h, UINT u, void *d), (hkl,h,u,d))
IMM_THUNK(BOOL, ImmSetCompositionStringW, (HIMC h, DWORD i, void *c, DWORD cl, void *r, DWORD rl), (h,i,c,cl,r,rl))
*/


/* ================================================================
 * C++ UNDEF stubs — hashed names from rename_coff_symbols.py
 *
 * All MSVC C++ mangled symbols in the extracted OBJ files are renamed
 * to __cx_<md5_hex[:16]> by the post-build Python script.  These 50
 * symbols are referenced but never defined in any Scintilla/Lexilla
 * OBJ — they normally come from the MSVC CRT/STL static libraries.
 *
 * Hash computation:  hashlib.md5(original_mangled_name).hexdigest()[:16]
 * ================================================================ */

/* --- operator new / delete --- */

/* ??2@YAPEAX_K@Z  =  void* operator new(size_t) */
void* __cx_327b03a5134e2843(size_t size)
{
    if (size == 0) size = 1;
    return HeapAlloc(GetProcessHeap(), 0, size);
}

/* ??_U@YAPEAX_K@Z  =  void* operator new[](size_t) */
void* __cx_11dbb2f3fcb10e66(size_t size)
{
    if (size == 0) size = 1;
    return HeapAlloc(GetProcessHeap(), 0, size);
}

/* ??3@YAXPEAX_K@Z  =  void operator delete(void*, size_t) */
void __cx_64074a2b61c98fa4(void* p, size_t s) { (void)s; if (p) HeapFree(GetProcessHeap(), 0, p); }

/* ??_V@YAXPEAX@Z  =  void operator delete[](void*) */
void __cx_51c79d72372a23f6(void* p) { if (p) HeapFree(GetProcessHeap(), 0, p); }

/* ??_V@YAXPEAX_K@Z  =  void operator delete[](void*, size_t) */
void __cx_56bd767d508a90a1(void* p, size_t s) { (void)s; if (p) HeapFree(GetProcessHeap(), 0, p); }


/* --- STL exception-throw functions (all terminate — Scintilla must not throw) --- */

__declspec(noreturn) static void _dsci_abort(void)
{
    TerminateProcess(GetCurrentProcess(), 3);
    for (;;) {}
}

/* ?_Xbad_function_call@std@@YAXXZ */
void __cx_00300aaad2d8da07(void) { _dsci_abort(); }

/* ?_Xlength_error@std@@YAXPEBD@Z */
void __cx_0c4a90828924ecb0(const char* m) { (void)m; _dsci_abort(); }

/* ?_Xout_of_range@std@@YAXPEBD@Z */
void __cx_98a8af6b280defce(const char* m) { (void)m; _dsci_abort(); }

/* ?_Xbad_alloc@std@@YAXXZ */
void __cx_dfd648c3abed46e9(void) { _dsci_abort(); }

/* ?_Xruntime_error@std@@YAXPEBD@Z */
void __cx_afc04dfd38660210(const char* m) { (void)m; _dsci_abort(); }

/* ?_Xregex_error@std@@YAXW4error_type@regex_constants@1@@Z */
void __cx_cb805850891a655a(int e) { (void)e; _dsci_abort(); }

/* ?_Throw_C_error@std@@YAXH@Z */
void __cx_3c83b492e1c74aab(int e) { (void)e; _dsci_abort(); }

/* ?_Throw_future_error@std@@YAXAEBVerror_code@1@@Z */
void __cx_7b9a22b9ce12c8f9(const void* ec) { (void)ec; _dsci_abort(); }

/* ?_Rethrow_future_exception@std@@YAXVexception_ptr@1@@Z */
void __cx_0dd7aa8db484bb66(const void* ep) { (void)ep; _dsci_abort(); }


/* --- Exception pointer management --- */

/* ?__ExceptionPtrCreate@@YAXPEAX@Z */
void __cx_77d937c28079c7b5(void* p) { if (p) { char* c = (char*)p; int i; for (i = 0; i < 16; i++) c[i] = 0; } }

/* ?__ExceptionPtrDestroy@@YAXPEAX@Z */
void __cx_a145811c74a0bdb3(void* p) { (void)p; }

/* ?__ExceptionPtrCopy@@YAXPEAXPEBX@Z */
void __cx_f2f84571fc034b6e(void* dst, const void* src) { memcpy(dst, src, 16); }

/* ?__ExceptionPtrAssign@@YAXPEAXPEBX@Z */
void __cx_18a1e13e1dfe3041(void* dst, const void* src) { memcpy(dst, src, 16); }

/* ?__ExceptionPtrRethrow@@YAXPEBX@Z */
void __cx_14254a4551472e53(const void* p) { (void)p; _dsci_abort(); }

/* ?__ExceptionPtrCurrentException@@YAXPEAX@Z */
void __cx_dc92e29f547071fb(void* p) { if (p) { char* c = (char*)p; int i; for (i = 0; i < 16; i++) c[i] = 0; } }

/* ?__ExceptionPtrToBool@@YA_NPEBX@Z */
int __cx_9b91ea7eb54067f4(const void* p) { (void)p; return 0; }


/* --- Locale / ctype stubs --- */

/* ?_Getgloballocale@locale@std@@CAPEAV_Locimp@12@XZ */
static char _dsci_dummy_locimp[256];
void* __cx_4545396d88a743d8(void) { return _dsci_dummy_locimp; }

/* ?_Init@locale@std@@CAPEAV_Locimp@12@_N@Z */
void* __cx_fef5fe9bb769ee2c(int b) { (void)b; return _dsci_dummy_locimp; }

/* ?_Facet_Register@std@@YAXPEAV_Facet_base@1@@Z */
void __cx_6864fb9a6629b76c(void* f) { (void)f; }

/* ?_Locinfo_ctor@_Locinfo@std@@SAXPEAV12@PEBD@Z */
void __cx_fef8dd9f6b23bdd2(void* li, const char* name) { (void)li; (void)name; }

/* ?_Locinfo_dtor@_Locinfo@std@@SAXPEAV12@@Z */
void __cx_df31a2230714f74e(void* li) { (void)li; }

/* ?_Syserror_map@std@@YAPEBDH@Z */
const char* __cx_18eeba04903dc2fd(int e) { (void)e; return "unknown error"; }

/* ?id@?$ctype@_W@std@@2V0locale@2@A  —  DATA: locale::id for ctype<wchar_t> */
static long long __cx_780884fe7adee3dd_storage[4] = {0};
long long* __cx_780884fe7adee3dd = __cx_780884fe7adee3dd_storage;

/* ?id@?$ctype@D@std@@2V0locale@2@A  —  DATA: locale::id for ctype<char> */
static long long __cx_9ac39dc43ff2e3d3_storage[4] = {0};
long long* __cx_9ac39dc43ff2e3d3 = __cx_9ac39dc43ff2e3d3_storage;

/* ?_Id_cnt@id@locale@std@@0HA  —  DATA: static int _Id_cnt */
int __cx_73c9a9b33b67a736 = 0;


/* --- _Lockit (locale locking, single-threaded stub) --- */

/* ??0_Lockit@std@@QEAA@H@Z  —  constructor: _Lockit(int) */
void __cx_9bfe7aa479c3ea49(void* thisptr, int kind) { (void)thisptr; (void)kind; }

/* ??1_Lockit@std@@QEAA@XZ  —  destructor: ~_Lockit() */
void __cx_87aa47748c5f9e5e(void* thisptr) { (void)thisptr; }


/* --- type_info vtable --- */

/* ??_7type_info@@6B@  —  vtable for type_info class */
static void _dsci_type_info_dtor(void* thisptr) { (void)thisptr; }
const void* __cx_28faa02efe594096[2] = { (const void*)_dsci_type_info_dtor, 0 };


/* --- Array ctor/dtor helpers (_ehvec_ctor / _ehvec_dtor) --- */

/* ??_L@YAXPEAX_K1P6AX0@Z2@Z  =  _ehvec_ctor(ptr, size, count, ctor, dtor) */
void __cx_4330633a2b962a4f(void* base, size_t elem_size, size_t count,
                           void (*ctor)(void*), void (*dtor)(void*))
{
    size_t i;
    (void)dtor;
    for (i = 0; i < count; i++)
        ctor((char*)base + i * elem_size);
}

/* ??_M@YAXPEAX_K1P6AX0@Z@Z  =  _ehvec_dtor(ptr, size, count, dtor) */
void __cx_787506475445d3e0(void* base, size_t elem_size, size_t count,
                           void (*dtor)(void*))
{
    size_t i = count;
    while (i-- > 0)
        dtor((char*)base + i * elem_size);
}


/* --- Concurrency Runtime / PPL stubs (never actually called by Scintilla) --- */

/* ?_Schedule_chore@details@Concurrency@@YAHPEAU_Threadpool_chore@12@@Z */
int __cx_1795fc0cd3c6d573(void* chore) { (void)chore; return 0; }

/* ?_Release_chore@details@Concurrency@@YAXPEAU_Threadpool_chore@12@@Z */
void __cx_8ed7b3754c586fc4(void* chore) { (void)chore; }

/* ?_ReportUnobservedException@details@Concurrency@@YAXXZ */
void __cx_56a05132d7f35b2f(void) {}

/* ?ReportUnhandledError@_ExceptionHolder@details@Concurrency@@AEAAXXZ */
void __cx_6a846508d2ed3644(void* thisptr) { (void)thisptr; }

/* ?GetCurrentThreadId@platform@details@Concurrency@@YAJXZ */
long __cx_8cbef89794d379fc(void) { return (long)GetCurrentThreadId(); }

/* ?_CallInContext@_ContextCallback@details@Concurrency@@QEBAXV?$function@$$A6AXXZ@... */
void __cx_443dffb11b52d723(const void* thisptr, void* fn_obj) { (void)thisptr; (void)fn_obj; }

/* ?_Capture@_ContextCallback@details@Concurrency@@AEAAXXZ */
void __cx_841360be89aadbeb(void* thisptr) { (void)thisptr; }

/* ?_Reset@_ContextCallback@details@Concurrency@@AEAAXXZ */
void __cx_f703344e75798cf7(void* thisptr) { (void)thisptr; }

/* ??0task_continuation_context@Concurrency@@AEAA@XZ */
void __cx_ec6d17d1fe89e58a(void* thisptr) { (void)thisptr; }

/* ?_LogScheduleTask@_TaskEventLogger@details@Concurrency@@QEAAX_N@Z */
void __cx_aba08805807c16a5(void* thisptr, int b) { (void)thisptr; (void)b; }

/* ?_LogTaskCompleted@_TaskEventLogger@details@Concurrency@@QEAAXXZ */
void __cx_82560e71b888e85b(void* thisptr) { (void)thisptr; }

/* ?_LogTaskExecutionCompleted@_TaskEventLogger@details@Concurrency@@QEAAXXZ */
void __cx_8666db0091b920ca(void* thisptr) { (void)thisptr; }

/* ?_LogWorkItemStarted@_TaskEventLogger@details@Concurrency@@QEAAXXZ */
void __cx_446d03151d2a1315(void* thisptr) { (void)thisptr; }

/* ?_LogWorkItemCompleted@_TaskEventLogger@details@Concurrency@@QEAAXXZ */
void __cx_3e8ce59abe4d4463(void* thisptr) { (void)thisptr; }

/* ?_LogCancelTask@_TaskEventLogger@details@Concurrency@@QEAAXXZ */
void __cx_883c1c61937880d0(void* thisptr) { (void)thisptr; }


#ifdef __cplusplus
}
#endif

/* ---- Weak-external stubs (auto-generated) ---- */
/* These are MSVC CRT/STL symbols referenced as weak externals.
   They have no definitions in Scintilla/Lexilla OBJ files.
   Providing no-op stubs satisfies the linker. */

void __cdecl __cx_07ccaa719d0186a1(void) { }
void __cdecl __cx_07f134f9fc8e1911(void) { }
void __cdecl __cx_08be2cd6d22bf4b7(void) { }
void __cdecl __cx_09bbc913a97c76b3(void) { }
void __cdecl __cx_0bca3fea21bee4ac(void) { }
void __cdecl __cx_0f5b7e95507126fc(void) { }
void __cdecl __cx_177959ee01061eb2(void) { }
void __cdecl __cx_179b6a66ca1b3d0e(void) { }
void __cdecl __cx_1b8f4c7ac2475319(void) { }
void __cdecl __cx_1ba1229a3149303d(void) { }
void __cdecl __cx_1d4dceecab5e53c1(void) { }
void __cdecl __cx_1ee94223a44e83d4(void) { }
void __cdecl __cx_206da755f94a895f(void) { }
void __cdecl __cx_225421db7ae686ff(void) { }
void __cdecl __cx_23c40f7952841413(void) { }
void __cdecl __cx_242445f0f897855b(void) { }
void __cdecl __cx_24e913823238ed34(void) { }
void __cdecl __cx_25b92914a0ea5f8a(void) { }
void __cdecl __cx_266237684661e02d(void) { }
void __cdecl __cx_29ac5a8926e57f85(void) { }
void __cdecl __cx_29d9d0ea4672e826(void) { }
void __cdecl __cx_2c022d6ceba457cb(void) { }
void __cdecl __cx_2e2440a488bb4cc1(void) { }
void __cdecl __cx_314c2d1052d5d16a(void) { }
void __cdecl __cx_3403c935a4983b8d(void) { }
void __cdecl __cx_3659702bb02dd8bc(void) { }
void __cdecl __cx_38d622626a1a2785(void) { }
void __cdecl __cx_3b4c1ba3f4f8ab7b(void) { }
void __cdecl __cx_3d194064cbfaa569(void) { }
void __cdecl __cx_3f66702aeb2f54b1(void) { }
void __cdecl __cx_4385fc4a4e6a5a8d(void) { }
void __cdecl __cx_45c3decc1f1d75f3(void) { }
void __cdecl __cx_47cb5ab0c94cf23c(void) { }
void __cdecl __cx_498fc064d96e2bbe(void) { }
void __cdecl __cx_49fd998aecf442b7(void) { }
void __cdecl __cx_4aeda388f7667db1(void) { }
void __cdecl __cx_4b74bdfdbd3975ef(void) { }
void __cdecl __cx_4bf1b6b8b2b6c160(void) { }
void __cdecl __cx_500880d47a1c24a8(void) { }
void __cdecl __cx_53123ced99c5697b(void) { }
void __cdecl __cx_5c9f592936a97728(void) { }
void __cdecl __cx_5f13c1b403f5314a(void) { }
void __cdecl __cx_625c38ce1514baa3(void) { }
void __cdecl __cx_6639ffef234dec03(void) { }
void __cdecl __cx_671d7db6006bba54(void) { }
void __cdecl __cx_67589a621d19adc1(void) { }
void __cdecl __cx_6b56e01f5880711c(void) { }
void __cdecl __cx_6b860b7ff37e9f0a(void) { }
void __cdecl __cx_6caeadaf1a4faa5e(void) { }
void __cdecl __cx_70b9489cac8efaae(void) { }
void __cdecl __cx_71090f7215a1c8fd(void) { }
void __cdecl __cx_730721b98c7d93ee(void) { }
void __cdecl __cx_7367ad6b79b04c0c(void) { }
void __cdecl __cx_738dc67074255610(void) { }
void __cdecl __cx_74ccd518d631109a(void) { }
void __cdecl __cx_785c57f438d1dca5(void) { }
void __cdecl __cx_789fd9a8b01115f9(void) { }
void __cdecl __cx_8035b38c5b3c9c2f(void) { }
void __cdecl __cx_810dbc7ecbabcd89(void) { }
void __cdecl __cx_8c715f8fb858c591(void) { }
void __cdecl __cx_8cd9c40815be438d(void) { }
void __cdecl __cx_8ce60cbfd68c331f(void) { }
void __cdecl __cx_8e5efce12c084798(void) { }
void __cdecl __cx_90edec18f70f610a(void) { }
void __cdecl __cx_9196808d6e0fe8b9(void) { }
void __cdecl __cx_91a74c57724b7ea5(void) { }
void __cdecl __cx_928b2c578dd82d02(void) { }
void __cdecl __cx_9512a373e0c7131c(void) { }
void __cdecl __cx_967e28f4ebc552ad(void) { }
void __cdecl __cx_96b230053c4b1d39(void) { }
void __cdecl __cx_983f0428dba3baaa(void) { }
void __cdecl __cx_9982f63dd32798ac(void) { }
void __cdecl __cx_9a513369cca1a196(void) { }
void __cdecl __cx_9bff2166cc2ab1d0(void) { }
void __cdecl __cx_9c130ac24acd0af7(void) { }
void __cdecl __cx_9c75819275f2aa91(void) { }
void __cdecl __cx_9df9ab253bc6b57b(void) { }
void __cdecl __cx_a0b5b136d7c54748(void) { }
void __cdecl __cx_a36971c5f7869d32(void) { }
void __cdecl __cx_a3c6f29aba42a876(void) { }
void __cdecl __cx_a507544fd9932039(void) { }
void __cdecl __cx_a61ff7f0761d68f8(void) { }
void __cdecl __cx_a6bea2ac56aca433(void) { }
void __cdecl __cx_aa5f25eec6f1cffb(void) { }
void __cdecl __cx_aa967035105e6a7e(void) { }
void __cdecl __cx_aaa5009bbe2769f5(void) { }
void __cdecl __cx_aae317465a6da4ce(void) { }
void __cdecl __cx_ab37e6979e4e7fc5(void) { }
void __cdecl __cx_abc7d05aab0fadb1(void) { }
void __cdecl __cx_aca0fab49037375d(void) { }
void __cdecl __cx_b330d98dc844ae79(void) { }
void __cdecl __cx_b45472e698a1bfc4(void) { }
void __cdecl __cx_b9a5f5294cafbe64(void) { }
void __cdecl __cx_bbaaa742f933ae88(void) { }
void __cdecl __cx_be0cd06643ec260e(void) { }
void __cdecl __cx_be8168df7aefcb2c(void) { }
void __cdecl __cx_bedeea1d7ac99321(void) { }
void __cdecl __cx_bf4088b5cd65b59b(void) { }
void __cdecl __cx_c2683efa1d732a98(void) { }
void __cdecl __cx_c4688b397c71382d(void) { }
void __cdecl __cx_c52f07643c95b6e9(void) { }
void __cdecl __cx_c662b3b680821044(void) { }
void __cdecl __cx_c9c7ee8a6e9965e8(void) { }
void __cdecl __cx_cbaa183dad493f17(void) { }
void __cdecl __cx_cdb63cd700bfc08a(void) { }
void __cdecl __cx_cf12153fd1edadad(void) { }
void __cdecl __cx_d15554832c1c3866(void) { }
void __cdecl __cx_d1da48834c81bb9c(void) { }
void __cdecl __cx_d2af06e23a1dc1b0(void) { }
void __cdecl __cx_d72513a4c1acb8d2(void) { }
void __cdecl __cx_d7495e611b4e6a38(void) { }
void __cdecl __cx_d791aed1f721be85(void) { }
void __cdecl __cx_d88f82856b5e1dfa(void) { }
void __cdecl __cx_d9a3e04e2bdeff80(void) { }
void __cdecl __cx_e01020598ba227e7(void) { }
void __cdecl __cx_e27b1c3d52d567d3(void) { }
void __cdecl __cx_e46b0e2457185d1c(void) { }
void __cdecl __cx_ec9d3d2aac73c78d(void) { }
void __cdecl __cx_edc4118c27ae30f2(void) { }
void __cdecl __cx_f04c031d140b7b42(void) { }
void __cdecl __cx_f0d520cb4a1ccb88(void) { }
void __cdecl __cx_f6cacf01540bd977(void) { }
void __cdecl __cx_f903c80e92992d34(void) { }
void __cdecl __cx_fdc592c863df22c1(void) { }
