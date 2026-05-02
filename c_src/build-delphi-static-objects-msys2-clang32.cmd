@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem ============================================================================
rem build-delphi-static-objects-msys2-clang32.cmd
rem
rem Compiles Scintilla + Lexilla sources with MSYS2 MinGW-w64 Clang 32-bit,
rem partially links them with libc++ via GNU ld, and sanitizes the combined
rem COFF i386 object for consumption by dcc32 (Delphi Win32 compiler).
rem
rem Prerequisites:
rem   - MSYS2 with mingw-w64-i686-clang and mingw-w64-i686-libc++ installed
rem     (pacman -S --needed mingw-w64-i686-clang mingw-w64-i686-libc++)
rem   - GNU ld from MSYS2 mingw32 (same install)
rem   - Python 3 (for coff_sanitize.py, must be on PATH)
rem
rem Output: source\obj\sci_combined_clang32.o
rem ============================================================================

rem --- Locate tools -----------------------------------------------------------
set "MINGW32=%MSYS2_ROOT%\mingw32"
if not defined MSYS2_ROOT set "MINGW32=D:\msys64\mingw32"

set "CLANG32=%MINGW32%\bin\clang++.exe"
set "LLVM_NM=%MINGW32%\bin\nm.exe"
set "LD32=%MINGW32%\bin\ld.exe"
set "MINGW_LIB=%MINGW32%\lib"

if not exist "%CLANG32%" (
    echo [ERROR] clang++ not found at "%CLANG32%"
    echo Install with: pacman -S --needed mingw-w64-i686-clang
    exit /b 1
)

if not exist "%LD32%" (
    echo [ERROR] ld.exe not found at "%LD32%"
    exit /b 1
)

where python >nul 2>nul || (
    echo [ERROR] python not found on PATH.
    exit /b 1
)

rem --- Paths ------------------------------------------------------------------
for %%I in ("%~dp0.") do set "C_SRC=%%~fI"
for %%I in ("%C_SRC%\..\source") do set "SOURCE=%%~fI"
set "OBJ_DIR=%SOURCE%\obj\test_clang32"
set "COMBINED_DIR=%SOURCE%\obj\clang32_combined"
set "OUTPUT_OBJ=%SOURCE%\obj\sci_combined_clang32.o"
set "SANITIZER=%C_SRC%\coff_sanitize.py"

set "SCI_DIR=%C_SRC%\scintilla"
set "LEX_DIR=%C_SRC%\lexilla"
set "SCI_INC=%SCI_DIR%\include"
set "LEX_INC=%LEX_DIR%\include"
set "BCC_SHIMS=%C_SRC%\bcc_shims"

rem Common compiler flags
rem NOTE: Clang 20 requires -fexceptions (unlike bcc64x/Clang 15 which tolerated
rem -fno-exceptions with try/catch present). Exceptions are handled by libc++abi.a.
rem -stdlib=libc++ forces libc++ ABI (NSt3__1* symbols matching libc++.a).
rem Without this, Clang uses GCC's libstdc++ headers producing NSt7__cxx11* symbols
rem that are NOT in libc++.a, causing hundreds of undefined symbols at Delphi link.
rem -fno-stack-protector eliminates ___stack_chk_fail/guard GCC runtime dependency.
set "CXXFLAGS=-c -std=c++17 -O2 -fexceptions -stdlib=libc++ -fno-stack-protector -DNDEBUG -DSCI_LEXER -D_CRT_SECURE_NO_WARNINGS"
set "CXXFLAGS=%CXXFLAGS% -I"%SCI_INC%" -I"%LEX_INC%""
set "CXXFLAGS=%CXXFLAGS% -I"%SCI_DIR%\src" -I"%SCI_DIR%\win32""
set "CXXFLAGS=%CXXFLAGS% -I"%LEX_DIR%\src" -I"%LEX_DIR%\lexlib""
set "CXXFLAGS=%CXXFLAGS% -I"%BCC_SHIMS%""

if not exist "%OBJ_DIR%" mkdir "%OBJ_DIR%"
if not exist "%COMBINED_DIR%" mkdir "%COMBINED_DIR%"

rem --- Phase 1: Compile all sources -------------------------------------------
echo === Phase 1: Compiling Scintilla/Lexilla sources with clang32 ===
set "COUNT=0"
set "ERRORS=0"

rem Scintilla core sources
for %%F in (
    "%SCI_DIR%\src\*.cxx"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    if not "!BASE!"=="ScintillaDLL" (
        "%CLANG32%" %CXXFLAGS% -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
        if errorlevel 1 (
            echo [FAIL] !BASE!.cxx
            "%CLANG32%" %CXXFLAGS% -o "%OBJ_DIR%\!BASE!.obj" "%%F" 2>&1 | findstr /i "error:"
            set /a ERRORS+=1
        )
    )
)

rem Scintilla win32 platform sources
for %%F in (
    "%SCI_DIR%\win32\*.cxx"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    if not "!BASE!"=="ScintillaDLL" (
        "%CLANG32%" %CXXFLAGS% -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
        if errorlevel 1 (
            echo [FAIL] !BASE!.cxx
            "%CLANG32%" %CXXFLAGS% -o "%OBJ_DIR%\!BASE!.obj" "%%F" 2>&1 | findstr /i "error:"
            set /a ERRORS+=1
        )
    )
)

rem Lexilla sources
for %%F in (
    "%LEX_DIR%\src\*.cxx"
    "%LEX_DIR%\lexlib\*.cxx"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    "%CLANG32%" %CXXFLAGS% -I"%LEX_DIR%\lexlib" -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
    if errorlevel 1 (
        echo [FAIL] !BASE!.cxx
        "%CLANG32%" %CXXFLAGS% -I"%LEX_DIR%\lexlib" -o "%OBJ_DIR%\!BASE!.obj" "%%F" 2>&1 | findstr /i "error:"
        set /a ERRORS+=1
    )
)

rem All lexer sources
for %%F in (
    "%LEX_DIR%\lexers\*.cxx"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    "%CLANG32%" %CXXFLAGS% -I"%LEX_DIR%\lexlib" -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
    if errorlevel 1 (
        echo [FAIL] !BASE!.cxx
        set /a ERRORS+=1
    )
)

rem SciBridge
set /a COUNT+=1
"%CLANG32%" %CXXFLAGS% -I"%SCI_DIR%\win32" -o "%OBJ_DIR%\SciBridge.obj" "%C_SRC%\SciBridge.cpp" >nul 2>&1
if errorlevel 1 (
    echo [FAIL] SciBridge.cpp
    "%CLANG32%" %CXXFLAGS% -I"%SCI_DIR%\win32" -o "%OBJ_DIR%\SciBridge.obj" "%C_SRC%\SciBridge.cpp" 2>&1 | findstr /i "error:"
    set /a ERRORS+=1
)

rem sci_crt_math_shim32.c must be compiled with -fno-builtin so Clang does NOT
rem replace function bodies (floorf, ceilf, etc.) with __builtin_* stubs.
rem Without -fno-builtin, Clang substitutes float variant bodies with built-in
rem implementations that generate E9 00 00 00 00 self-loop stubs on x86-32.
set /a COUNT+=1
"%CLANG32%" -x c -c -O2 -fno-builtin -o "%OBJ_DIR%\sci_crt_math_shim32.obj" "%C_SRC%\sci_crt_math_shim32.c" >nul 2>&1
if errorlevel 1 (
    echo [FAIL] sci_crt_math_shim32.c
    "%CLANG32%" -x c -c -O2 -fno-builtin -o "%OBJ_DIR%\sci_crt_math_shim32.obj" "%C_SRC%\sci_crt_math_shim32.c" 2>&1 | findstr /i "error:"
    set /a ERRORS+=1
)

rem C stubs: C++ runtime stubs + CXA stubs (Win32 variants)
rem Use -x c to force C language mode (clang++ defaults to C++ for all files)
for %%F in (
    "%C_SRC%\sci_cpprt_stubs_win32.c"
    "%C_SRC%\sci_crt_ucrt_stubs_win32.c"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    "%CLANG32%" -x c -c -O2 -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
    if errorlevel 1 (
        echo [FAIL] !BASE!.c
        "%CLANG32%" -x c -c -O2 -o "%OBJ_DIR%\!BASE!.obj" "%%F" 2>&1 | findstr /i "error:"
        set /a ERRORS+=1
    )
)

echo [INFO] Compiled %COUNT% sources, %ERRORS% errors.
if %ERRORS% GTR 0 (
    echo [ERROR] Compilation failed. Fix errors and retry.
    exit /b 1
)

rem --- Phase 2: Create response file and partial link -------------------------
echo === Phase 2: Partial linking with GNU ld (i386pe) ===
set "RSP=%COMBINED_DIR%\ld_final_input.rsp"

rem Write math shim32 first (Win32 x87 asm — no EB FE stubs unlike sci_crt_math_shim.c)
> "%RSP%" echo %COMBINED_DIR:\=/%/sci_crt_math_shim32.o
copy /y "%OBJ_DIR%\sci_crt_math_shim32.obj" "%COMBINED_DIR%\sci_crt_math_shim32.o" >nul

rem Add all Scintilla/Lexilla OBJs (exclude DLL entry and math shim already added)
for /f "delims=" %%F in ('dir /b /a-d /on "%OBJ_DIR%\*.obj" 2^>nul') do (
    set "FN=%%~nF"
    if not "!FN!"=="sci_crt_math_shim32" if not "!FN!"=="ScintillaDLL" (
        >> "%RSP%" echo %OBJ_DIR:\=/%/%%F
    )
)

rem Add C++ runtime library (i686 version from MSYS2 mingw32)
>> "%RSP%" echo "%MINGW_LIB:\=/%/libc++.a"
>> "%RSP%" echo "%MINGW_LIB:\=/%/libc++abi.a"
if exist "%MINGW_LIB%\libunwind.a" >> "%RSP%" echo "%MINGW_LIB:\=/%/libunwind.a"
rem GCC intrinsics (___divdi3, ___emutls_get_address, ___once_proxy, __alloca, etc.)
set "LIBGCC_DIR=%MINGW_LIB%\gcc\i686-w64-mingw32\15.1.0"
if exist "%LIBGCC_DIR%\libgcc_eh.a" >> "%RSP%" echo "%LIBGCC_DIR:\=/%/libgcc_eh.a"
if exist "%LIBGCC_DIR%\libgcc.a"    >> "%RSP%" echo "%LIBGCC_DIR:\=/%/libgcc.a"
rem MinGW pthreads (Win32 thread API wrapper — std::mutex/thread use this)
if exist "%MINGW_LIB%\libwinpthread.a" >> "%RSP%" echo "%MINGW_LIB:\=/%/libwinpthread.a"
rem MinGW extension CRT (___mingw_fprintf, ___mingw_sscanf, ___mingw_vfprintf, etc.)
if exist "%MINGW_LIB%\libmingwex.a" >> "%RSP%" echo "%MINGW_LIB:\=/%/libmingwex.a"
rem MinGW32 base (provides __fpreset and other MinGW base symbols)
if exist "%MINGW_LIB%\libmingw32.a" >> "%RSP%" echo "%MINGW_LIB:\=/%/libmingw32.a"
rem Import libs: embed __imp__XXX@N IAT stubs + _XXX@N thunks into the combined OBJ.
rem dcc32 then resolves any Delphi external references to these thunks from the OBJ;
rem at load time the PE loader patches the embedded .idata entries to the real DLLs.
rem CRT / UCRT / MinGW runtime
if exist "%MINGW_LIB%\libmsvcrt.a"   >> "%RSP%" echo "%MINGW_LIB:\=/%/libmsvcrt.a"
if exist "%MINGW_LIB%\libucrtbase.a" >> "%RSP%" echo "%MINGW_LIB:\=/%/libucrtbase.a"
rem Windows API: kernel32, user32, gdi32, advapi32
if exist "%MINGW_LIB%\libkernel32.a"  >> "%RSP%" echo "%MINGW_LIB:\=/%/libkernel32.a"
if exist "%MINGW_LIB%\libuser32.a"    >> "%RSP%" echo "%MINGW_LIB:\=/%/libuser32.a"
if exist "%MINGW_LIB%\libgdi32.a"     >> "%RSP%" echo "%MINGW_LIB:\=/%/libgdi32.a"
if exist "%MINGW_LIB%\libadvapi32.a"  >> "%RSP%" echo "%MINGW_LIB:\=/%/libadvapi32.a"
rem Windows API: COM / OLE
if exist "%MINGW_LIB%\libole32.a"    >> "%RSP%" echo "%MINGW_LIB:\=/%/libole32.a"
if exist "%MINGW_LIB%\liboleaut32.a" >> "%RSP%" echo "%MINGW_LIB:\=/%/liboleaut32.a"
rem Windows API: extra display / IME
if exist "%MINGW_LIB%\libmsimg32.a"  >> "%RSP%" echo "%MINGW_LIB:\=/%/libmsimg32.a"
if exist "%MINGW_LIB%\libimm32.a"    >> "%RSP%" echo "%MINGW_LIB:\=/%/libimm32.a"

set "RAW_OBJ=%COMBINED_DIR%\sci_final_combined.o"
"%LD32%" -m i386pe -r --discard-all --allow-multiple-definition ^
    -o "%RAW_OBJ:\=/%" "@%RSP%" 2>nul
if errorlevel 1 (
    echo [ERROR] GNU ld partial link failed. Retrying with verbose output...
    "%LD32%" -m i386pe -r --discard-all --allow-multiple-definition ^
        -o "%RAW_OBJ:\=/%" "@%RSP%"
    exit /b 1
)
echo [INFO] Partial link complete: %RAW_OBJ%

rem --- Phase 3: Sanitize for Delphi -------------------------------------------
echo === Phase 3: Sanitizing COFF for dcc32 ===
python "%SANITIZER%" "%RAW_OBJ%" "%OUTPUT_OBJ%"
if errorlevel 1 (
    echo [ERROR] COFF sanitization failed.
    exit /b 1
)

rem --- Phase 3.5: Merge duplicate sections so dcc32 applies all relocations ----
rem After Phase 3, the OBJ has 4000+ sections with duplicate names (ex-COMDAT).
rem dcc32's {$L} linker fails to apply IMAGE_REL_I386_DIR32 relocations beyond
rem a few hundred sections, leaving BSS symbols at 0x00000000 and causing
rem NULL-pointer writes at runtime (e.g. ScintillaWin::Register crash).
rem A second ld -r pass with a SECTIONS linker script merges all same-named
rem sections into single output sections, reducing the count to ~9.
echo === Phase 3.5: Merging duplicate COFF sections (dcc32 relocation fix) ===
set "MERGED_OBJ=%COMBINED_DIR%\sci_merged_clang32.o"
set "MERGE_LD=%C_SRC%\merge_sections_i386.ld"
"%LD32%" -m i386pe -r --allow-multiple-definition -T "%MERGE_LD:\=/%" ^
    -o "%MERGED_OBJ:\=/%" "%OUTPUT_OBJ:\=/%"
if errorlevel 1 (
    echo [ERROR] Section-merge ld pass failed.
    "%LD32%" -m i386pe -r --allow-multiple-definition -T "%MERGE_LD:\=/%" ^
        -o "%MERGED_OBJ:\=/%" "%OUTPUT_OBJ:\=/%" 2>&1
    exit /b 1
)
copy /y "%MERGED_OBJ%" "%OUTPUT_OBJ%" >nul
echo [INFO] Section merge complete.

rem --- Phase 4: Strip DWARF debug sections (prevent dcc32 F2084 AV crash) ------
echo === Phase 4: Stripping DWARF debug sections ===
set "OBJCOPY32=%MINGW32%\bin\objcopy.exe"
if not exist "%OBJCOPY32%" (
    echo [ERROR] objcopy not found: %OBJCOPY32%
    echo Install with: pacman -S --needed mingw-w64-i686-binutils
    exit /b 1
)
"%OBJCOPY32%" -R .debug_info -R .debug_aranges -R .debug_abbrev -R .debug_line ^
    -R .debug_str -R .debug_line_str -R .debug_loclists -R .debug_rnglists ^
    "%OUTPUT_OBJ%" "%OUTPUT_OBJ%"
if errorlevel 1 (
    echo [ERROR] objcopy debug strip failed.
    exit /b 1
)
echo [INFO] DWARF debug sections stripped.

rem --- Dump constructor symbols for inc generation ----------------------------
echo === Constructor symbols (for SciBridge.Ctors.win32.inc) ===
"%LLVM_NM%" "%OUTPUT_OBJ%" 2>nul | findstr "__GLOBAL__sub_I_\|__GLOBAL__I_"

rem --- Phase 5: Verify math-symbol integrity (no infinite-loop stubs) ---------
echo === Phase 5: Verifying math symbol integrity ===
set "VERIFIER=%C_SRC%\verify_math_syms.py"
python "%VERIFIER%" "%OUTPUT_OBJ%"
if errorlevel 1 (
    echo [ERROR] Math symbol verification failed.  See output above.
    echo         This usually means coff_sanitize.py PASS 1.8 did not run or a new
    echo         stub symbol was introduced.  Check MATH_SYMS_I386 in coff_sanitize.py.
    exit /b 1
)

rem --- Summary ----------------------------------------------------------------
echo.
echo === Build complete ===
for %%F in ("%OUTPUT_OBJ%") do echo Output: %%~fF (%%~zF bytes)
echo.
echo To use: define SCINTILLA_STATIC_LINKING in your Delphi project
echo and add DScintillaBridge to your uses clause.
