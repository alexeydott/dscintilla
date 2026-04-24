@echo off
setlocal EnableExtensions

if "%~3"=="" (
  echo Usage: %~nx0 ^<x86^|x64^> ^<dll-name^> ^<output-dir^>
  exit /b 1
)

set "ARCH=%~1"
set "DLL_NAME=%~2"
set "OUT_DIR=%~f3"
set "SCRIPT_DIR=%~dp0"
set "SCI_WIN32_DIR=%SCRIPT_DIR%scintilla\win32"
set "LEX_SRC_DIR=%SCRIPT_DIR%lexilla\src"
set "SCI_BIN_DIR=%SCRIPT_DIR%scintilla\bin"
set "LEX_BIN_DIR=%SCRIPT_DIR%lexilla\bin"
set "DEF_FILE=%SCRIPT_DIR%scintilla-lexilla-combined.def"

if /I "%ARCH%"=="x86" (
  set "MACHINE=X86"
  set "BRIDGE_PLATFORM=32"
) else if /I "%ARCH%"=="x64" (
  set "MACHINE=X64"
  set "BRIDGE_PLATFORM=64"
) else (
  echo Unsupported architecture "%ARCH%".
  exit /b 1
)

where cl >NUL 2>NUL
if errorlevel 1 (
  echo Visual Studio build environment is not initialized.
  echo Run the architecture-specific wrapper script or call vcvars*.bat first.
  exit /b 1
)

set "CL=/FS %CL%"

if not exist "%DEF_FILE%" (
  echo Missing export definition file: "%DEF_FILE%"
  exit /b 1
)

if not exist "%OUT_DIR%" (
  mkdir "%OUT_DIR%"
  if errorlevel 1 (
    echo Failed to create output directory "%OUT_DIR%".
    exit /b 1
  )
)

echo === Building Scintilla static-runtime artifacts for %ARCH% ===
pushd "%SCI_WIN32_DIR%"
if errorlevel 1 (
  echo Failed to enter "%SCI_WIN32_DIR%".
  exit /b 1
)

nmake /nologo -f scintilla.mak clean
if errorlevel 1 goto :sci_fail

nmake /nologo -f scintilla.mak
if errorlevel 1 goto :sci_fail

popd

echo === Building Lexilla static-runtime artifacts for %ARCH% ===
pushd "%LEX_SRC_DIR%"
if errorlevel 1 (
  echo Failed to enter "%LEX_SRC_DIR%".
  exit /b 1
)

nmake /nologo -f lexilla.mak clean
if errorlevel 1 goto :lex_fail

nmake /nologo -f lexilla.mak
if errorlevel 1 goto :lex_fail

popd

set "SCI_DLL_OBJ=%SCI_WIN32_DIR%\obj\ScintillaDLL.obj"
set "SCI_RES=%SCI_WIN32_DIR%\obj\ScintRes.res"
set "SCI_LIB=%SCI_BIN_DIR%\libscintilla.lib"
set "LEX_LIB=%LEX_BIN_DIR%\liblexilla.lib"
set "OUT_DLL=%OUT_DIR%\%DLL_NAME%"
set "OUT_LIB=%OUT_DIR%\%~n2.lib"
set "OUT_PDB=%OUT_DIR%\%~n2.pdb"
set "OUT_BRIDGE_OBJ=%SCRIPT_DIR%..\source\scibridge%BRIDGE_PLATFORM%.obj"

if not exist "%SCI_DLL_OBJ%" (
  echo Missing Scintilla DLL object: "%SCI_DLL_OBJ%"
  exit /b 1
)

if not exist "%SCI_RES%" (
  echo Missing Scintilla resource: "%SCI_RES%"
  exit /b 1
)

if not exist "%SCI_LIB%" (
  echo Missing Scintilla static library: "%SCI_LIB%"
  exit /b 1
)

if not exist "%LEX_LIB%" (
  echo Missing Lexilla static library: "%LEX_LIB%"
  exit /b 1
)

echo === Linking combined Scintilla + Lexilla DLL ===
link /NOLOGO /DLL /MACHINE:%MACHINE% /OUT:"%OUT_DLL%" /IMPLIB:"%OUT_LIB%" /PDB:"%OUT_PDB%" /OPT:REF /OPT:NOICF /LTCG /IGNORE:4197 /DEBUG /SUBSYSTEM:WINDOWS /DEF:"%DEF_FILE%" "%SCI_DLL_OBJ%" "%SCI_RES%" "%SCI_LIB%" /WHOLEARCHIVE:"%LEX_LIB%" KERNEL32.lib USER32.lib GDI32.lib IMM32.lib OLE32.lib OLEAUT32.lib ADVAPI32.lib
if errorlevel 1 (
  echo Linking failed for "%OUT_DLL%".
  exit /b 1
)

echo === Building SciBridge bridge object ===
call "%SCRIPT_DIR%build-sci-bridge.bat" %ARCH%
if errorlevel 1 (
  echo SciBridge build failed for %ARCH%.
  exit /b 1
)

echo === Done ===
echo Output DLL: "%OUT_DLL%"
echo Import LIB: "%OUT_LIB%"
echo PDB: "%OUT_PDB%"
echo Output OBJ: "%OUT_BRIDGE_OBJ%"
exit /b 0

:sci_fail
set "ERR=%errorlevel%"
popd
exit /b %ERR%

:lex_fail
set "ERR=%errorlevel%"
popd
exit /b %ERR%
