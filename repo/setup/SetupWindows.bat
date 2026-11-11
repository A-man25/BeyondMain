@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "SCRIPT=%~dp0Windows\Setup.ps1"
if not exist "%SCRIPT%" (
    echo [ERROR] Could not find Setup\Windows\Setup.ps1.
    pause
    exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" (
    echo.
    echo [ERROR] BeyondMain setup failed. See details above.
    pause
)
exit /b %RESULT%
