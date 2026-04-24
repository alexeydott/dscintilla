@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem ============================================================================
rem build-delphi-static-objects-bcc64x.cmd
rem
rem Compiles Scintilla + Lexilla sources with Embarcadero bcc64x (Clang 15),
rem partially links them with libc++/libunwind via GNU ld, and sanitizes the
rem combined COFF object for consumption by dcc64 (Delphi Win64 compiler).
rem
rem Prerequisites:
rem   - Embarcadero RAD Studio 23.0 (bcc64x, llvm-nm)
rem   - GNU ld  (Strawberry Perl or standalone Binutils, must be on PATH)
rem   - Python 3 (for coff_sanitize.py, must be on PATH)
rem
rem Output: source\obj\sci_combined_bcc64x.o
rem ============================================================================

rem --- Locate tools -----------------------------------------------------------
set "RAD_ROOT=D:\Embarcadero RAD Studio\23.0"
set "BCC64X=%RAD_ROOT%\bin64\bcc64x.exe"
set "LLVM_NM=%RAD_ROOT%\bin64\llvm-nm.exe"
set "MINGW_LIB=%RAD_ROOT%\x86_64-w64-mingw32\lib"
set "CLANG_LIB=%RAD_ROOT%\lib\clang\15.0.7\lib\windows"

if not exist "%BCC64X%" (
    echo [ERROR] bcc64x not found at "%BCC64X%"
    exit /b 1
)

where ld.exe >nul 2>nul || (
    echo [ERROR] ld.exe (GNU ld) not found on PATH.
    echo Install Strawberry Perl or add Binutils to PATH.
    exit /b 1
)

where python >nul 2>nul || (
    echo [ERROR] python not found on PATH.
    exit /b 1
)

rem --- Paths ------------------------------------------------------------------
for %%I in ("%~dp0.") do set "C_SRC=%%~fI"
for %%I in ("%C_SRC%\..\source") do set "SOURCE=%%~fI"
set "OBJ_DIR=%SOURCE%\obj\test_bcc64x"
set "COMBINED_DIR=%SOURCE%\obj\bcc64x_combined"
set "OUTPUT_OBJ=%SOURCE%\obj\sci_combined_bcc64x.o"
set "SANITIZER=%C_SRC%\coff_sanitize.py"

set "SCI_DIR=%C_SRC%\scintilla"
set "LEX_DIR=%C_SRC%\lexilla"
set "SCI_INC=%SCI_DIR%\include"
set "LEX_INC=%LEX_DIR%\include"
set "BCC_SHIMS=%C_SRC%\bcc_shims"

rem Common compiler flags
set "CXXFLAGS=-c -std=c++17 -O2 -fno-exceptions -DNDEBUG -DSCI_LEXER -D_CRT_SECURE_NO_WARNINGS"
set "CXXFLAGS=%CXXFLAGS% -I"%SCI_INC%" -I"%LEX_INC%""
set "CXXFLAGS=%CXXFLAGS% -I"%SCI_DIR%\src" -I"%SCI_DIR%\win32""
set "CXXFLAGS=%CXXFLAGS% -I"%LEX_DIR%\src" -I"%LEX_DIR%\lexlib""
set "CXXFLAGS=%CXXFLAGS% -I"%BCC_SHIMS%""

if not exist "%OBJ_DIR%" mkdir "%OBJ_DIR%"
if not exist "%COMBINED_DIR%" mkdir "%COMBINED_DIR%"

rem --- Phase 1: Compile all sources -------------------------------------------
echo === Phase 1: Compiling Scintilla/Lexilla sources with bcc64x ===
set "COUNT=0"
set "ERRORS=0"

rem Scintilla core sources
for %%F in (
    "%SCI_DIR%\src\*.cxx"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    if not "!BASE!"=="ScintillaDLL" (
        "%BCC64X%" %CXXFLAGS% -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
        if errorlevel 1 (
            echo [FAIL] !BASE!.cxx
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
        "%BCC64X%" %CXXFLAGS% -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
        if errorlevel 1 (
            echo [FAIL] !BASE!.cxx
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
    "%BCC64X%" %CXXFLAGS% -I"%LEX_DIR%\lexlib" -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
    if errorlevel 1 (
        echo [FAIL] !BASE!.cxx
        set /a ERRORS+=1
    )
)

rem All lexer sources
for %%F in (
    "%LEX_DIR%\lexers\*.cxx"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    "%BCC64X%" %CXXFLAGS% -I"%LEX_DIR%\lexlib" -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
    if errorlevel 1 (
        echo [FAIL] !BASE!.cxx
        set /a ERRORS+=1
    )
)

rem SciBridge
set /a COUNT+=1
"%BCC64X%" %CXXFLAGS% -I"%SCI_DIR%\win32" -o "%OBJ_DIR%\SciBridge.obj" "%C_SRC%\SciBridge.cpp" >nul 2>&1
if errorlevel 1 (
    echo [FAIL] SciBridge.cpp
    set /a ERRORS+=1
)

rem C stubs: math shim + C++ runtime stubs + UCRT inline stubs
for %%F in (
    "%C_SRC%\sci_crt_math_shim.c"
    "%C_SRC%\sci_cpprt_stubs.c"
    "%C_SRC%\sci_crt_ucrt_stubs.c"
) do (
    set /a COUNT+=1
    set "BASE=%%~nF"
    "%BCC64X%" -c -O2 -o "%OBJ_DIR%\!BASE!.obj" "%%F" >nul 2>&1
    if errorlevel 1 (
        echo [FAIL] !BASE!.c
        set /a ERRORS+=1
    )
)

echo [INFO] Compiled %COUNT% sources, %ERRORS% errors.
if %ERRORS% GTR 0 (
    echo [ERROR] Compilation failed. Fix errors and retry.
    exit /b 1
)

rem --- Phase 2: Create response file and partial link -------------------------
echo === Phase 2: Partial linking with GNU ld ===
set "RSP=%COMBINED_DIR%\ld_final_input.rsp"

rem Write math shim first (resolves round/trunc before Scintilla references them)
> "%RSP%" echo %COMBINED_DIR:\=/%/sci_crt_math_shim.o
rem Copy the math shim OBJ to the combined dir
copy /y "%OBJ_DIR%\sci_crt_math_shim.obj" "%COMBINED_DIR%\sci_crt_math_shim.o" >nul

rem Add all Scintilla/Lexilla OBJs (exclude DLL entry and math/stubs already added)
for /f "delims=" %%F in ('dir /b /a-d /on "%OBJ_DIR%\*.obj" 2^>nul') do (
    set "FN=%%~nF"
    if not "!FN!"=="sci_crt_math_shim" if not "!FN!"=="ScintillaDLL" (
        >> "%RSP%" echo %OBJ_DIR:\=/%/%%F
    )
)

rem Add C++ runtime libraries
>> "%RSP%" echo "%MINGW_LIB:\=/%/libc++.a"
>> "%RSP%" echo "%MINGW_LIB:\=/%/libc++abi.a"
>> "%RSP%" echo "%MINGW_LIB:\=/%/libunwind.a"
>> "%RSP%" echo "%CLANG_LIB:\=/%/libclang_rt.builtins-x86_64.a"

set "RAW_OBJ=%COMBINED_DIR%\sci_final_combined.o"
ld.exe -r --discard-all --allow-multiple-definition -o "%RAW_OBJ:\=/%"  "@%RSP%" 2>nul
if errorlevel 1 (
    echo [ERROR] GNU ld partial link failed.
    exit /b 1
)
echo [INFO] Partial link complete: %RAW_OBJ%

rem --- Phase 3: Sanitize for Delphi -------------------------------------------
echo === Phase 3: Sanitizing COFF for dcc64 ===
python "%SANITIZER%" "%RAW_OBJ%" "%OUTPUT_OBJ%"
if errorlevel 1 (
    echo [ERROR] COFF sanitization failed.
    exit /b 1
)

rem --- Summary ----------------------------------------------------------------
echo.
echo === Build complete ===
for %%F in ("%OUTPUT_OBJ%") do echo Output: %%~fF (%%~zF bytes)
echo.
echo To use: define SCINLILLA_STATIC_LINKING in your Delphi project
echo and add DScintillaBridge to your uses clause.
