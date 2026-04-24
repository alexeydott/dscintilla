@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%") do set "SCRIPT_DIR=%%~fI"
for %%I in ("%SCRIPT_DIR%\..\..") do set "REPO_ROOT=%%~fI"

set "ISCC=D:\tools\InnoSetup\6\ISCC.exe"
set "ISS_FILE=%SCRIPT_DIR%\DSciSrcVwrSetup.iss"
set "PREVIEW_DLL=%REPO_ROOT%\bin64\DSciSrcVwr.64.dll"
set "SCINTILLA_DLL=%REPO_ROOT%\bin64\scintilla64.dll"
set "OUTPUT_DIR=%REPO_ROOT%\bin64"
set "APP_VERSION="

if not exist "%ISCC%" (
  echo ERROR: Inno Setup compiler not found: "%ISCC%"
  exit /b 1
)

if not exist "%ISS_FILE%" (
  echo ERROR: Installer script not found: "%ISS_FILE%"
  exit /b 1
)

if not exist "%PREVIEW_DLL%" (
  echo ERROR: Preview handler DLL not found: "%PREVIEW_DLL%"
  exit /b 1
)

if not exist "%SCINTILLA_DLL%" (
  echo ERROR: Scintilla DLL not found: "%SCINTILLA_DLL%"
  exit /b 1
)

for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-Item -LiteralPath '%PREVIEW_DLL%').VersionInfo.FileVersion.Trim()"`) do (
  set "APP_VERSION=%%I"
)

if not defined APP_VERSION (
  set "APP_VERSION=0.0.0.0"
)

if not exist "%OUTPUT_DIR%" (
  mkdir "%OUTPUT_DIR%"
)

echo Building DSciSrcVwr installer version %APP_VERSION%
echo Source DLL: "%PREVIEW_DLL%"
echo Scintilla DLL: "%SCINTILLA_DLL%"
echo Output dir: "%OUTPUT_DIR%"

"%ISCC%" "%ISS_FILE%" /DMyAppVersion=%APP_VERSION% /DPreviewDllSource=%PREVIEW_DLL% /DScintillaDllSource=%SCINTILLA_DLL% /DInstallerOutputDir=%OUTPUT_DIR%
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo ERROR: Inno Setup build failed with exit code %EXIT_CODE%.
  exit /b %EXIT_CODE%
)

echo Installer created successfully.
echo Output dir: "%OUTPUT_DIR%"
exit /b 0
