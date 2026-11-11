
@echo off
setlocal EnableExtensions
title BEYONDMAIN - Windows Setup

set "ROOT=%~dp0"
set "TOOLS=%ROOT%build\build"
set "PREMAKE=%TOOLS%\premake5.exe"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

echo.
echo =========================================
echo       BEYONDMAIN - WINDOWS LAUNCHER
echo =========================================
echo.

if not exist "%PREMAKE%" (
    echo [ERROR] premake5.exe not found.
    pause
    exit /b 1
)

if not exist "%VSWHERE%" (
    echo [ERROR] Visual Studio Build Tools not found.
    pause
    exit /b 1
)

set "VSROOT="

for /f "usebackq delims=" %%I in (`
    "%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
`) do set "VSROOT=%%I"

if not defined VSROOT (
    echo [ERROR] Install Visual Studio C++ Build Tools.
    pause
    exit /b 1
)

set "MSBUILD=%VSROOT%\MSBuild\Current\Bin\MSBuild.exe"

for %%I in ("%VSROOT%") do set "VSVERSION=%%~nxI"

if "%VSVERSION%"=="18" (
    set "ACTION=vs2026"
) else (
    set "ACTION=vs2022"
)

echo [1/4] Generating %ACTION% project...

pushd "%TOOLS%"
"%PREMAKE%" %ACTION%
if errorlevel 1 (
    popd
    echo [ERROR] Premake generation failed.
    pause
    exit /b 1
)
popd

set "SOLUTION=%ROOT%proj\BeyondMain.slnx"

if not exist "%SOLUTION%" (
    set "SOLUTION=%ROOT%proj\BeyondMain.sln"
)

if not exist "%SOLUTION%" (
    echo [ERROR] Solution missing in repo\proj.
    pause
    exit /b 1
)

echo [2/4] Initializing MSVC environment...

call "%VSROOT%\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 exit /b 1

echo [3/4] Building BeyondMain...

"%MSBUILD%" "%SOLUTION%" /t:Build /p:Configuration=Debug /p:Platform=x64 /m /verbosity:minimal

if errorlevel 1 (
    echo [ERROR] Build failed.
    pause
    exit /b 1
)

echo [4/4] Launching VS Code...

where code >nul 2>&1
if errorlevel 1 (
    echo [ERROR] VS Code CLI not found in PATH.
    pause
    exit /b 1
)

code --install-extension ms-vscode.cpptools --force >nul 2>&1
start "" code "%ROOT%"

echo [SUCCESS] BeyondMain ready.
exit /b 0
