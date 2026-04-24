@echo off
setlocal EnableExtensions

call "D:\VisualStudio2019\VC\Auxiliary\Build\vcvars32.bat"
if errorlevel 1 exit /b %errorlevel%

call "%~dp0build-scintilla-common.cmd" x86 scintilla.dll "%~dp0..\bin32"
exit /b %errorlevel%
