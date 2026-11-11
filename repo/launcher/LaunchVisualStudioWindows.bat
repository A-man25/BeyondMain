@echo off
setlocal EnableExtensions
set "ROOT=%~dp0..\"
set "SLN=%ROOT%proj\BeyondMain.slnx"
if not exist "%SLN%" set "SLN=%ROOT%proj\BeyondMain.sln"
if not exist "%SLN%" (
    echo [INFO] Solution missing. Generating with portable setup...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%setup\Windows\Build.ps1" -Mode Generate
    if errorlevel 1 (
        pause
        exit /b 1
    )
    set "SLN=%ROOT%proj\BeyondMain.slnx"
    if not exist "%SLN%" set "SLN=%ROOT%proj\BeyondMain.sln"
)
if not exist "%SLN%" (
    echo [ERROR] Solution not found after generation.
    pause
    exit /b 1
)
start "" "%SLN%"
exit /b 0
