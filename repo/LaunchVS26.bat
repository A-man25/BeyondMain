
@echo off
setlocal EnableExtensions DisableDelayedExpansion
title BEYONDMAIN - Visual Studio Launcher

rem ============================================================
rem BEYONDMAIN | VISUAL STUDIO LAUNCHER
rem ============================================================

set "ROOT=%~dp0"
set "SOLUTION="

echo.
echo ========================================
echo       BEYONDMAIN - PROJECT LAUNCHER
echo ========================================
echo.

rem Search for a generated Visual Studio solution
for /r "%ROOT%" %%F in (*.sln *.slnx) do (
    if not defined SOLUTION (
        set "SOLUTION=%%~fF"
    )
)

if not defined SOLUTION (
    echo [ERROR] No Visual Studio solution found.
    echo Run GenerateProjects.bat first.
    pause
    exit /b 1
)

rem Locate installed Visual Studio
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "DEVENV="

if exist "%VSWHERE%" (
    for /f "usebackq delims=" %%I in (`
        "%VSWHERE%" -latest -products * -property productPath
    `) do set "DEVENV=%%I"
)

echo [INFO] Solution: %SOLUTION%

if defined DEVENV (
    echo [INFO] Launching Visual Studio...
    start "" "%DEVENV%" "%SOLUTION%"
) else (
    echo [INFO] Using Windows file association...
    start "" "%SOLUTION%"
)

exit /b 0
