/*
 * sci_crt_ucrt_stubs.c - Stubs for UCRT-inline functions
 *
 * atexit, sscanf, vfprintf, fprintf are NOT exported by ucrtbase.dll.
 * They are inline wrappers in UCRT headers backed by __stdio_common_*
 * internal functions that ARE exported.  We provide minimal wrappers.
 *
 * No standard headers are included to avoid __declspec(dllimport)
 * conflicts with our local definitions.
 *
 * Compile with: bcc64x -c -O2 sci_crt_ucrt_stubs.c
 */

/* UCRT internal functions (exported by ucrtbase.dll) */
extern int __stdio_common_vsscanf(
    unsigned long long options,
    const char *buffer,
    unsigned long long buffer_count,
    const char *format,
    void *locale,
    __builtin_va_list arglist);

extern int __stdio_common_vfprintf(
    unsigned long long options,
    void *stream,
    const char *format,
    void *locale,
    __builtin_va_list arglist);

/* ---- atexit ----
   Stores callbacks; SciStatic_RunDestructors invokes them in reverse
   order during Delphi finalization. */
static void (*_sci_atexit_funcs[64])(void);
static int _sci_atexit_count;

int atexit(void (*func)(void))
{
    if (_sci_atexit_count >= 64) return 1;
    _sci_atexit_funcs[_sci_atexit_count++] = func;
    return 0;
}

/* ---- __cxa_atexit / __cxa_finalize ----
   Override libc++abi's implementations so we control the callback list.
   C++ global constructors (_GLOBAL__sub_I_*) register static destructors
   via __cxa_atexit; we store them and run them at finalization.
   Supersedes libc++abi's version thanks to --allow-multiple-definition
   in the ld -r partial link (our .obj comes before libc++abi.a). */
typedef void (*_sci_cxa_dtor_fn)(void *);
#define SCI_MAX_CXA 256
static struct { _sci_cxa_dtor_fn fn; void *arg; } _sci_cxa[SCI_MAX_CXA];
static int _sci_cxa_count;

int __cxa_atexit(_sci_cxa_dtor_fn dtor, void *arg, void *dso_handle)
{
    (void)dso_handle;
    if (_sci_cxa_count >= SCI_MAX_CXA) return -1;
    _sci_cxa[_sci_cxa_count].fn = dtor;
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
   Called from Delphi finalization to run C++ static destructors
   and atexit callbacks. Must be called after all Scintilla/Lexilla
   instances are destroyed. */
void SciStatic_RunDestructors(void)
{
    int i;
    __cxa_finalize((void *)0);
    for (i = _sci_atexit_count - 1; i >= 0; i--) {
        if (_sci_atexit_funcs[i])
            _sci_atexit_funcs[i]();
    }
    _sci_atexit_count = 0;
}

/* ---- sscanf ----
   Wrapper around __stdio_common_vsscanf. */
int sscanf(const char *buffer, const char *format, ...)
{
    __builtin_va_list args;
    __builtin_va_start(args, format);
    int result = __stdio_common_vsscanf(
        0, buffer, (unsigned long long)-1, format, (void *)0, args);
    __builtin_va_end(args);
    return result >= 0 ? result : -1;
}

/* ---- vfprintf ----
   Wrapper around __stdio_common_vfprintf. */
int vfprintf(void *stream, const char *format, __builtin_va_list args)
{
    return __stdio_common_vfprintf(0, stream, format, (void *)0, args);
}

/* ---- fprintf ----
   Wrapper using vfprintf.  Currently eliminated by Delphi smart linker,
   but provided for safety against future code paths. */
int fprintf(void *stream, const char *format, ...)
{
    __builtin_va_list args;
    __builtin_va_start(args, format);
    int result = vfprintf(stream, format, args);
    __builtin_va_end(args);
    return result;
}
