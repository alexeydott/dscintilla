@echo off
setlocal EnableExtensions EnableDelayedExpansion

if "%~1"=="" goto :usage

set "ARCH=%~1"
if /I "%ARCH%"=="x86" (
  set "PLAT_NAME=win32"
  set "BITS=32"
  set "REQ_TGT=x86"
  set "VCVARS_BASENAME=vcvars32.bat"
) else if /I "%ARCH%"=="x64" (
  set "PLAT_NAME=win64"
  set "BITS=64"
  set "REQ_TGT=x64"
  set "VCVARS_BASENAME=vcvarsx86_amd64.bat"
) else (
  echo [ERROR] Unsupported architecture "%ARCH%". Use x86 or x64.
  exit /b 1
)

call :ensure_msvc_env || exit /b 1

echo [INFO] MSVC target environment: VSCMD_ARG_TGT_ARCH="%VSCMD_ARG_TGT_ARCH%"

for %%I in ("%~dp0.") do set "C_SRC_ROOT=%%~fI"
for %%I in ("%C_SRC_ROOT%\..\source") do set "SOURCE_ROOT=%%~fI"
for %%I in ("%SOURCE_ROOT%\obj") do set "OBJ_ROOT=%%~fI"
for %%I in ("%OBJ_ROOT%\scibridge%BITS%.obj") do set "BRIDGE_OBJ=%%~fI"
set "SCI_WIN32_DIR=%C_SRC_ROOT%\scintilla\win32"
set "LEX_SRC_DIR=%C_SRC_ROOT%\lexilla\src"
set "SCI_BIN_DIR=%C_SRC_ROOT%\scintilla\bin"
set "LEX_BIN_DIR=%C_SRC_ROOT%\lexilla\bin"
set "SCI_INCLUDE=%C_SRC_ROOT%\scintilla\include"
set "LEX_INCLUDE=%C_SRC_ROOT%\lexilla\include"
set "SCI_LIB=%SCI_BIN_DIR%\libscintilla.lib"
set "LEX_LIB=%LEX_BIN_DIR%\liblexilla.lib"
set "BRIDGE_CPP=%C_SRC_ROOT%\SciBridge.cpp"
set "CRT_SHIM_C=%C_SRC_ROOT%\SciBridge_CRT_x64.c"
for %%I in ("%OBJ_ROOT%\sciCRT%BITS%.obj") do set "CRT_SHIM_OBJ=%%~fI"
set "IMPORTS_C=%C_SRC_ROOT%\SciBridge_Imports_x64.c"
for %%I in ("%OBJ_ROOT%\sciImports%BITS%.obj") do set "IMPORTS_OBJ=%%~fI"
for %%I in ("%OBJ_ROOT%\sciAll%BITS%.obj") do set "COMBINED_OBJ=%%~fI"
set "FORCELINK_INC=%SOURCE_ROOT%\SciBridge.ForceLink.%PLAT_NAME%.inc"
set "INC_FILE_COMMON=%SOURCE_ROOT%\SciBridge.Objects.inc"
set "INC_FILE_WIN32=%SOURCE_ROOT%\SciBridge.Objects.win32.inc"
set "INC_FILE_WIN64=%SOURCE_ROOT%\SciBridge.Objects.win64.inc"
set "INC_FILE_PLATFORM=%SOURCE_ROOT%\SciBridge.Objects.%PLAT_NAME%.inc"

rem Override upstream release flags for Delphi-compatible objects:
rem  - No /GL (LTCG) — produces proprietary bitcode; Delphi needs standard COFF.
rem  - /GS-         — disables buffer-security checks (removes __security_cookie deps).
rem  - /Gs999999    — raises stack-probe threshold so __chkstk is never emitted.
set "DELPHI_CXX_RELEASE=-O2 -MT -DNDEBUG -GS- -Gs999999 -Gy-"

where cl >nul 2>nul || (echo [ERROR] cl.exe not found in PATH.& exit /b 1)
where lib >nul 2>nul || (echo [ERROR] lib.exe not found in PATH.& exit /b 1)
where dumpbin >nul 2>nul || (echo [ERROR] dumpbin.exe not found in PATH.& exit /b 1)

if not exist "%SOURCE_ROOT%" mkdir "%SOURCE_ROOT%" >nul 2>nul
if not exist "%OBJ_ROOT%" mkdir "%OBJ_ROOT%" >nul 2>nul
if not exist "%OBJ_ROOT%" (
  echo [ERROR] Failed to create "%OBJ_ROOT%".
  exit /b 1
)

if not exist "%BRIDGE_CPP%" (
  echo [ERROR] Missing bridge source: "%BRIDGE_CPP%"
  exit /b 1
)
if not exist "%SCI_INCLUDE%\ILexer.h" (
  echo [ERROR] Missing "%SCI_INCLUDE%\ILexer.h"
  exit /b 1
)
if not exist "%LEX_INCLUDE%\Lexilla.h" (
  echo [ERROR] Missing "%LEX_INCLUDE%\Lexilla.h"
  exit /b 1
)

echo === Building Scintilla for %ARCH% ===
pushd "%SCI_WIN32_DIR%" || exit /b 1
nmake /nologo -f scintilla.mak clean || goto :fail_popd
nmake /nologo -f scintilla.mak "CXXNDEBUG=%DELPHI_CXX_RELEASE%" || goto :fail_popd
popd

echo === Building Lexilla for %ARCH% ===
pushd "%LEX_SRC_DIR%" || exit /b 1
nmake /nologo -f lexilla.mak clean || goto :fail_popd
nmake /nologo -f lexilla.mak "CXXNDEBUG=%DELPHI_CXX_RELEASE%" || goto :fail_popd
popd

if not exist "%SCI_LIB%" (
  echo [ERROR] Missing "%SCI_LIB%"
  exit /b 1
)
if not exist "%LEX_LIB%" (
  echo [ERROR] Missing "%LEX_LIB%"
  exit /b 1
)

echo === Cleaning previous %ARCH% objects from obj\ ===
del /f /q "%OBJ_ROOT%\*%BITS%.obj" >nul 2>nul

echo === Building SciBridge object for %ARCH% ===
echo [INFO] Bridge output: "%BRIDGE_OBJ%"
if exist "%BRIDGE_OBJ%" del /f /q "%BRIDGE_OBJ%" >nul 2>nul
cl /nologo /c /TP /std:c++17 /GS- /GR- /EHsc /Zl /W3 /I "%SCI_INCLUDE%" /I "%LEX_INCLUDE%" /I "%SCI_WIN32_DIR%" /Fo"%BRIDGE_OBJ%" "%BRIDGE_CPP%"
if errorlevel 1 (
  echo [ERROR] Compilation failed for "%BRIDGE_CPP%".
  exit /b 1
)
if not exist "%BRIDGE_OBJ%" (
  echo [ERROR] Bridge object was not created: "%BRIDGE_OBJ%"
  exit /b 1
)

call :verify_machine "%BRIDGE_OBJ%" "%ARCH%" || exit /b 1

rem --- Build CRT compatibility shim (Win64 only) ---
if /I "%ARCH%"=="x64" (
  echo === Building CRT shim for x64 ===
  echo [INFO] CRT shim output: "%CRT_SHIM_OBJ%"
  if exist "%CRT_SHIM_OBJ%" del /f /q "%CRT_SHIM_OBJ%" >nul 2>nul
  cl /nologo /c /O2 /Oi- /Zl /GS- /Gs999999 /W3 /Fo"%CRT_SHIM_OBJ%" "%CRT_SHIM_C%"
  if errorlevel 1 (
    echo [ERROR] CRT shim compilation failed.
    exit /b 1
  )
  call :verify_machine "%CRT_SHIM_OBJ%" "%ARCH%" || exit /b 1
)

echo === Extracting Scintilla objects to obj\ ===
call :extract_all_renamed "%SCI_LIB%" "%OBJ_ROOT%" "%BITS%" || exit /b 1

echo === Extracting Lexilla objects to obj\ ===
call :extract_all_renamed "%LEX_LIB%" "%OBJ_ROOT%" "%BITS%" || exit /b 1

rem --- Rename Delphi-conflicting symbols (round -> _dsci_round etc.) ---
echo === Renaming Delphi-conflicting symbols in OBJ files ===
python "%~dp0rename_coff_symbols.py" "%OBJ_ROOT%" "%BITS%"
if errorlevel 1 (
  echo [ERROR] Symbol renaming failed.
  exit /b 1
)

rem --- Build imports resolver (Win64 only) ---
if /I "%ARCH%"=="x64" (
  echo === Building imports resolver for x64 ===
  echo [INFO] Imports output: "%IMPORTS_OBJ%"
  if exist "%IMPORTS_OBJ%" del /f /q "%IMPORTS_OBJ%" >nul 2>nul
  cl /nologo /c /Zl /GS- /W3 /O2 /Fo"%IMPORTS_OBJ%" "%IMPORTS_C%"
  if errorlevel 1 (
    echo [ERROR] Imports resolver compilation failed.
    exit /b 1
  )
  call :verify_machine "%IMPORTS_OBJ%" "%ARCH%" || exit /b 1
)

rem --- Generate Delphi force-link include (Win64 only) ---
if /I "%ARCH%"=="x64" (
  echo === Generating cross-OBJ force-link include ===
  python "%~dp0generate_forcelink_inc.py" "%OBJ_ROOT%" "%BITS%" "%FORCELINK_INC%"
  if errorlevel 1 (
    echo [WARN] Force-link generation reported truly undefined symbols.
    echo [WARN] The build may still succeed if they are weak externals.
  )
)

echo === Regenerating Delphi include files ===
call :generate_single_platform_inc "%INC_FILE_PLATFORM%" "%BITS%" || exit /b 1
call :generate_common_wrapper_inc "%INC_FILE_COMMON%" || exit /b 1

echo === Done ===
echo Object directory      : "%OBJ_ROOT%"
echo Bridge object         : "%BRIDGE_OBJ%"
echo Common wrapper include: "%INC_FILE_COMMON%"
echo Platform include      : "%INC_FILE_PLATFORM%"
if /I "%ARCH%"=="x64" echo ForceLink include     : "%FORCELINK_INC%"
exit /b 0

:usage
echo Usage: %~nx0 ^<x86^|x64^>
exit /b 1

:ensure_msvc_env
if /I "%REQ_TGT%"=="x86" (
  if /I "%VSCMD_ARG_TGT_ARCH%"=="x86" exit /b 0
) else (
  if /I "%VSCMD_ARG_TGT_ARCH%"=="x64" exit /b 0
  if /I "%VSCMD_ARG_TGT_ARCH%"=="amd64" exit /b 0
)

set "VCVARS="
if exist "D:\VisualStudio2019\VC\Auxiliary\Build\%VCVARS_BASENAME%" set "VCVARS=D:\VisualStudio2019\VC\Auxiliary\Build\%VCVARS_BASENAME%"
if not defined VCVARS if defined VS170COMNTOOLS if exist "%VS170COMNTOOLS%..\..\VC\Auxiliary\Build\%VCVARS_BASENAME%" set "VCVARS=%VS170COMNTOOLS%..\..\VC\Auxiliary\Build\%VCVARS_BASENAME%"
if not defined VCVARS if defined VS160COMNTOOLS if exist "%VS160COMNTOOLS%..\..\VC\Auxiliary\Build\%VCVARS_BASENAME%" set "VCVARS=%VS160COMNTOOLS%..\..\VC\Auxiliary\Build\%VCVARS_BASENAME%"
if not defined VCVARS if defined VS150COMNTOOLS if exist "%VS150COMNTOOLS%..\..\VC\Auxiliary\Build\%VCVARS_BASENAME%" set "VCVARS=%VS150COMNTOOLS%..\..\VC\Auxiliary\Build\%VCVARS_BASENAME%"

if not defined VCVARS (
  echo [ERROR] Could not locate %VCVARS_BASENAME%.
  echo [ERROR] Either run this script from the proper VS Developer Command Prompt,
  echo [ERROR] or adjust the hard-coded Visual Studio path in this script.
  exit /b 1
)

echo [INFO] Initializing MSVC environment via "%VCVARS%"
call "%VCVARS%"
if errorlevel 1 (
  echo [ERROR] Failed to initialize MSVC environment using "%VCVARS%".
  exit /b 1
)

if /I "%REQ_TGT%"=="x86" (
  if /I not "%VSCMD_ARG_TGT_ARCH%"=="x86" (
    echo [ERROR] Requested x86, but MSVC environment reports "%VSCMD_ARG_TGT_ARCH%".
    exit /b 1
  )
) else (
  if /I not "%VSCMD_ARG_TGT_ARCH%"=="x64" if /I not "%VSCMD_ARG_TGT_ARCH%"=="amd64" (
    echo [ERROR] Requested x64, but MSVC environment reports "%VSCMD_ARG_TGT_ARCH%".
    exit /b 1
  )
)
exit /b 0

:fail_popd
set "ERR=%ERRORLEVEL%"
popd
exit /b %ERR%

:verify_machine
set "OBJ=%~f1"
set "EXPECT=%~2"
set "VMTMP=%TEMP%\sci_verify_%RANDOM%_%RANDOM%.txt"
if not defined OBJ (
  echo [ERROR] verify_machine received an empty object path.
  exit /b 1
)
if not exist "%OBJ%" (
  echo [ERROR] Object file does not exist: "%OBJ%"
  exit /b 1
)
dumpbin /headers "%OBJ%" > "%VMTMP%" 2>&1
if errorlevel 1 (
  type "%VMTMP%"
  del "%VMTMP%" >nul 2>nul
  echo [ERROR] dumpbin failed for "%OBJ%".
  exit /b 1
)
if /I "%EXPECT%"=="x86" (
  findstr /I /C:" machine (x86)" "%VMTMP%" >nul
) else (
  findstr /I /C:" machine (x64)" "%VMTMP%" >nul
)
if errorlevel 1 (
  type "%VMTMP%"
  del "%VMTMP%" >nul 2>nul
  echo [ERROR] "%OBJ%" does not match requested architecture "%EXPECT%".
  exit /b 1
)
del "%VMTMP%" >nul 2>nul
exit /b 0

:extract_all_renamed
set "LIBFILE=%~f1"
set "DEST=%~f2"
set "BITS=%~3"
set "LIST=%TEMP%\sci_liblist_%RANDOM%_%RANDOM%.txt"
lib /nologo /list "%LIBFILE%" > "%LIST%"
if errorlevel 1 (
  del "%LIST%" >nul 2>nul
  echo [ERROR] Failed to list members of "%LIBFILE%".
  exit /b 1
)
for /f "usebackq delims=" %%M in ("%LIST%") do (
  if not "%%~M"=="" call :extract_one_renamed "%LIBFILE%" "%%~M" "%DEST%" "%BITS%"
  if errorlevel 1 (
    del "%LIST%" >nul 2>nul
    exit /b 1
  )
)
del "%LIST%" >nul 2>nul
exit /b 0

:extract_one_renamed
set "LIBFILE=%~f1"
set "MEMBER=%~2"
set "DEST=%~f3"
set "BITS=%~4"
set "BASE=%~n2"
set "OUTOBJ=%DEST%\sci%BASE%%BITS%.obj"
if exist "%OUTOBJ%" (
  echo [ERROR] Target object already exists, name collision detected: "%OUTOBJ%"
  echo [ERROR] Source member: "%MEMBER%"
  echo [ERROR] Library      : "%LIBFILE%"
  exit /b 1
)
lib /nologo /extract:"%MEMBER%" /out:"%OUTOBJ%" "%LIBFILE%" >nul
if errorlevel 1 (
  echo [ERROR] Failed to extract "%MEMBER%" from "%LIBFILE%".
  exit /b 1
)
exit /b 0

:generate_common_wrapper_inc
set "OUT=%~f1"
> "%OUT%" echo { Auto-generated. Do not edit manually. }
>> "%OUT%" echo { Stable wrapper include. }
>> "%OUT%" echo { This file is platform-agnostic and may be regenerated on any build. }
>> "%OUT%" echo.
>> "%OUT%" echo {$IFDEF WIN32}
>> "%OUT%" echo   {$I 'SciBridge.Objects.win32.inc'}
>> "%OUT%" echo {$ENDIF}
>> "%OUT%" echo.
>> "%OUT%" echo {$IFDEF WIN64}
>> "%OUT%" echo   {$I 'SciBridge.Objects.win64.inc'}
>> "%OUT%" echo {$ENDIF}
exit /b 0

:generate_single_platform_inc
set "OUT=%~f1"
set "BITS=%~2"
> "%OUT%" echo { Auto-generated. Do not edit manually. }
>> "%OUT%" echo { Generated for platform bits: %BITS% }
>> "%OUT%" echo { Paths are relative to this .inc file location. }
>> "%OUT%" echo.
for /f "delims=" %%F in ('dir /b /a-d /on "%OBJ_ROOT%\*%BITS%.obj" 2^>nul') do >> "%OUT%" echo {$L 'obj\%%F'}
exit /b 0
