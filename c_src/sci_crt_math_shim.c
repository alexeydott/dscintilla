/* Provide round/trunc/ceil/floor so they appear as DEFINED in the combined OBJ.
   Delphi compiler intrinsics Round and Trunc collide with the C function names
   and cause E2068 if they appear as UNDEF references.
   Compiled with bcc64x -O2, these compile to single SSE instructions. */
double round(double x) { return __builtin_round(x); }
float roundf(float x)  { return __builtin_roundf(x); }
long lround(double x)  { return __builtin_lround(x); }
long lroundf(float x)  { return __builtin_lroundf(x); }
double trunc(double x)  { return __builtin_trunc(x); }
double ceil(double x)   { return __builtin_ceil(x); }
float ceilf(float x)    { return __builtin_ceilf(x); }
double floor(double x)  { return __builtin_floor(x); }
float floorf(float x)   { return __builtin_floorf(x); }
