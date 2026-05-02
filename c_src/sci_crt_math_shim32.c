/*
 * sci_crt_math_shim32.c
 *
 * Win32 (x86-32) self-contained implementations of C99 math functions.
 *
 * Problem: sci_crt_math_shim.c uses __builtin_lround / __builtin_floor etc.,
 * but Clang32 on x86-32 (without -msse4.1) cannot emit these inline —
 * it generates EB FE / E9 00 00 00 00 infinite-loop stubs instead.
 *
 * Solution: use x87 FPU inline assembly directly.  No external function
 * calls are made, so these implementations are self-contained.
 *
 * ABI (Windows x86 cdecl):
 *   double/float args : on stack at [esp+4]
 *   double/float return: in FPU st(0)
 *   long return        : in EAX
 *
 * This file must be compiled FIRST in Phase 2 (linked before other OBJs)
 * so --allow-multiple-definition keeps these definitions over any stubs
 * from libc++/libmingwex.
 *
 * Compile: clang -x c -c -O2 -o sci_crt_math_shim32.obj sci_crt_math_shim32.c
 */

#ifdef __GNUC__   /* Clang and GCC only — MSVC has no inline asm with this syntax */

/* ---- FPU rounding-mode helpers -------------------------------------------
 *
 * FPU control word bits [11:10] (RC = Rounding Control):
 *   0x0000  round to nearest (even)   — default
 *   0x0400  round toward -inf         — floor
 *   0x0800  round toward +inf         — ceil
 *   0x0C00  round toward zero         — trunc
 */

/*
 * _fpu_rnd: temporarily sets FPU rounding mode to MODE_BITS, applies
 * FRNDINT to X, stores double result into *R, then restores the mode.
 */
static void _fpu_rnd(double x, double *r, unsigned short mode_bits)
{
    unsigned short cw_save, cw_new;
    __asm__ volatile ("fstcw %0" : "=m" (cw_save));
    cw_new = (unsigned short)((cw_save & 0xF3FFU) | mode_bits);
    __asm__ volatile (
        "fldcw %2\n\t"   /* load new rounding mode */
        "fldl  %1\n\t"   /* push x onto FPU stack   */
        "frndint\n\t"    /* round to integer         */
        "fstpl %0\n\t"   /* store double + pop stack */
        "fldcw %3\n\t"   /* restore saved mode       */
        : "=m" (*r)
        : "m" (x), "m" (cw_new), "m" (cw_save)
    );
}

/* ---- double-returning functions ------------------------------------------ */

double trunc(double x) { double r; _fpu_rnd(x, &r, 0x0C00U); return r; }
double floor(double x) { double r; _fpu_rnd(x, &r, 0x0400U); return r; }
double ceil (double x) { double r; _fpu_rnd(x, &r, 0x0800U); return r; }

double round(double x)
{
    /* round half away from zero: shift by ±0.5, then truncate */
    double t = x + (x >= 0.0 ? 0.5 : -0.5);
    double r;
    _fpu_rnd(t, &r, 0x0C00U);
    return r;
}

/* ---- float variants ------------------------------------------------------- */

float floorf(float x) { return (float)floor((double)x); }
float ceilf (float x) { return (float)ceil ((double)x); }
float roundf(float x) { return (float)round((double)x); }
float truncf(float x) { return (float)trunc((double)x); }

/* ---- integer-returning functions ------------------------------------------ */

/*
 * lround / lroundf: load arg with FLDL/FLDS, round to nearest integer
 * with FRNDINT (FPU default mode = nearest-even), then store as int32
 * with FISTPL.  The return value (long) is returned in EAX by Clang.
 */
long lround(double x)
{
    long r;
    __asm__ volatile (
        "fldl   %1\n\t"   /* push double x        */
        "frndint\n\t"     /* round to nearest int */
        "fistpl %0\n\t"   /* store int32 + pop    */
        : "=m" (r)
        : "m"  (x)
    );
    return r;
}

long lroundf(float x)
{
    long r;
    __asm__ volatile (
        "flds   %1\n\t"
        "frndint\n\t"
        "fistpl %0\n\t"
        : "=m" (r)
        : "m"  (x)
    );
    return r;
}

#endif /* __GNUC__ */
