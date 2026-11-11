@echo off
setlocal EnableExtensions
set "ROOT=%~dp0..\"
if not exist "%ROOT%setup\SetupWindows.bat" (
    echo [ERROR] setup\SetupWindows.bat missing. Extract setup.zip at repo root first.
    pause
    exit /b 1
)
call "%ROOT%setup\SetupWindows.bat"
exit /b %ERRORLEVEL%
