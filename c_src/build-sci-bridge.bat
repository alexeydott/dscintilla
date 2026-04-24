@echo off
setlocal EnableExtensions

if "%~1"=="" (
  echo Usage: %~nx0 ^<x86^|x64^>
  exit /b 1
)

set "ARCH=%~1"
if /I "%ARCH%"=="x86" (
  set "PLATFORM=32"
) else if /I "%ARCH%"=="x64" (
  set "PLATFORM=64"
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

set "SCRIPT_DIR=%~dp0"
set "SRC_CPP=%SCRIPT_DIR%SciBridge.cpp"
set "SCI_INC=%SCRIPT_DIR%scintilla\include"
set "SCI_WIN32=%SCRIPT_DIR%scintilla\win32"
set "LEX_INC=%SCRIPT_DIR%lexilla\include"
set "OUT_DIR=%SCRIPT_DIR%..\source"
set "OUT_OBJ=%OUT_DIR%\scibridge%PLATFORM%.obj"

if not exist "%SRC_CPP%" (
  echo Missing source file: "%SRC_CPP%"
  exit /b 1
)

if not exist "%SCI_INC%" (
  echo Missing include directory: "%SCI_INC%"
  exit /b 1
)

if not exist "%SCI_WIN32%" (
  echo Missing include directory: "%SCI_WIN32%"
  exit /b 1
)

if not exist "%LEX_INC%" (
  echo Missing include directory: "%LEX_INC%"
  exit /b 1
)

if not exist "%OUT_DIR%" (
  mkdir "%OUT_DIR%"
  if errorlevel 1 (
    echo Failed to create output directory "%OUT_DIR%".
    exit /b 1
  )
)

echo === Building SciBridge object for %ARCH% ===
cl /nologo /c /TP /std:c++17 /Zc:__cplusplus /permissive- /EHsc /GR- /W4 /DWIN32 /D_WINDOWS /D_CRT_SECURE_NO_WARNINGS /I"%SCI_INC%" /I"%SCI_WIN32%" /I"%LEX_INC%" /Fo"%OUT_OBJ%" "%SRC_CPP%"
if errorlevel 1 (
  echo Compilation failed for "%SRC_CPP%".
  exit /b 1
)

echo Output OBJ: "%OUT_OBJ%"
exit /b 0
