{
  Minimal external declarations for Win32 static linking (MinGW i686 Clang).

  The combined clang32 OBJ is now fully self-contained for all Windows API IAT
  references: kernel32, user32, gdi32, advapi32, ole32, oleaut32, msimg32, imm32,
  msvcrt, and ucrtbase import stubs are all embedded during Phase 2 partial link.

  The only symbol that has no MinGW import-lib thunk is _atexit (msvcrt atexit),
  so it is the sole remaining Delphi-side external declaration.
}

{ ---- msvcrt.dll : atexit — the one CRT function with no MinGW thunk ---- }
{ OBJ calls _atexit (cdecl prefix + 'atexit'); msvcrt.dll exports 'atexit'. }
procedure _atexit(fn: Pointer); cdecl; external 'msvcrt.dll' name 'atexit';
