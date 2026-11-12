@echo off
rem Entrada para CMD ou PowerShell; a politica vale so para este processo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-android.ps1" %*
exit /b %ERRORLEVEL%
