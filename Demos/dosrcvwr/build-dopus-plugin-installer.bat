@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "REPO_ROOT=%%~fI"
if not defined ISCC set "ISCC=D:\tools\InnoSetup\6\ISCC.exe"
set "ISS_FILE=%SCRIPT_DIR%DOSrcVwrSetup.iss"
set "PLUGIN_DLL=%REPO_ROOT%\bin64\DOSrcVwr.dll"
set "SCINTILLA_DLL=%REPO_ROOT%\bin64\scintilla64.dll"
set "OUTPUT_DIR=%REPO_ROOT%\bin64"

if not exist "%ISCC%" (
  echo ERROR: Inno Setup compiler not found: "%ISCC%"
  exit /b 1
)
if not exist "%PLUGIN_DLL%" (
  echo ERROR: Build the Win64 DOSrcVwr plugin first: "%PLUGIN_DLL%"
  exit /b 1
)
if not exist "%SCINTILLA_DLL%" (
  echo ERROR: Scintilla DLL not found: "%SCINTILLA_DLL%"
  exit /b 1
)
set "APP_VERSION="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "(Get-Item -LiteralPath $env:PLUGIN_DLL).VersionInfo.FileVersion.Trim()"`) do set "APP_VERSION=%%I"
if not defined APP_VERSION (
  echo ERROR: Cannot read the plugin file version.
  exit /b 1
)
echo Building DOSrcVwr installer version %APP_VERSION%
"%ISCC%" "%ISS_FILE%" "/DMyAppVersion=%APP_VERSION%" "/DPluginDllSource=%PLUGIN_DLL%" "/DScintillaDllSource=%SCINTILLA_DLL%" "/DInstallerOutputDir=%OUTPUT_DIR%"
exit /b %errorlevel%
