/*
 * sci_crt_ucrt_stubs_win32.c - C runtime stubs for Win32 Delphi static linking
 *
 * Win32 variant.  MinGW-compiled Scintilla links against msvcrt.dll for basic
 * C functions (malloc, printf, etc.) which Delphi already provides through
 * System.Win.Crtl.  This file only stubs __cxa_atexit/__cxa_finalize for
 * explicit C++ destructor control, and exports SciStatic_RunDestructors.
 *
 * Compile with: clang -c -O2 sci_crt_ucrt_stubs_win32.c
 */

typedef void (*_sci_cxa_dtor_fn)(void *);
#define SCI_MAX_CXA 256
static struct { _sci_cxa_dtor_fn fn; void *arg; } _sci_cxa[SCI_MAX_CXA];
static int _sci_cxa_count;

/* ---- __cxa_atexit / __cxa_finalize ---- */

int __cxa_atexit(_sci_cxa_dtor_fn dtor, void *arg, void *dso_handle)
{
    (void)dso_handle;
    if (_sci_cxa_count >= SCI_MAX_CXA) return -1;
    _sci_cxa[_sci_cxa_count].fn  = dtor;
    _sci_cxa[_sci_cxa_count].arg = arg;
    _sci_cxa_count++;
    return 0;
}

void __cxa_finalize(void *dso_handle)
{
    int i;
    (void)dso_handle;
    for (i = _sci_cxa_count - 1; i >= 0; i--) {
        if (_sci_cxa[i].fn) {
            _sci_cxa[i].fn(_sci_cxa[i].arg);
            _sci_cxa[i].fn = 0;
        }
    }
    _sci_cxa_count = 0;
}

/* ---- SciStatic_RunDestructors ----
   Called from Delphi finalization to run C++ static destructors.
   Must be called after all Scintilla/Lexilla instances are destroyed. */
void SciStatic_RunDestructors(void)
{
    __cxa_finalize((void *)0);
}

/* ---- __setjmp3 stub ----
   MSVCRT internal used by libc++abi SEH integration.  Not called during
   normal Scintilla operation (only if C++ exceptions cross SEH frames). */
int _setjmp3(void *env, int n)
{
    (void)env;
    (void)n;
    return 0;
}

/* ---- __ms_fwprintf stub ----
   MinGW-internal wide-char printf wrapper used by libc++abi error
   reporting (std::terminate etc.).  Returns -1 (failure) silently;
   never triggered during normal Scintilla operation. */
int __ms_fwprintf(void *stream, const void *fmt, ...)
{
    (void)stream;
    (void)fmt;
    return -1;
}

/* ---- __mingw_aligned_malloc / __mingw_aligned_free ----
   MinGW-internal wrappers used by libc++ aligned allocators.
   Delegate to ucrtbase _aligned_malloc / _aligned_free. */
extern void *_aligned_malloc(unsigned int size, unsigned int align);
extern void  _aligned_free(void *p);

void *__mingw_aligned_malloc(unsigned int size, unsigned int align)
{
    return _aligned_malloc(size, align);
}

void __mingw_aligned_free(void *p)
{
    _aligned_free(p);
}
