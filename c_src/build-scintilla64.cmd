@echo off
setlocal EnableExtensions

call "D:\VisualStudio2019\VC\Auxiliary\Build\vcvarsx86_amd64.bat"
if errorlevel 1 exit /b %errorlevel%

call "%~dp0build-scintilla-common.cmd" x64 scintilla64.dll "%~dp0..\bin64"
exit /b %errorlevel%
