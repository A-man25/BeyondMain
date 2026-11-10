@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem ============================================================================
rem   BEYONDMAIN - PROJECT FORGE v9
rem   Location: repo\build\build\GenerateProjects.bat
rem   Source folders are 100%% user-managed. This script NEVER creates, renames,
rem   or populates folders under repo\src\.
rem
rem   Usage:
rem       GenerateProjects.bat
rem       GenerateProjects.bat vs2022
rem       GenerateProjects.bat vs2026 --no-open
rem ============================================================================

set "GENERATOR=vs2026"
set "OPEN_SOLUTION=1"
for %%A in (%*) do (
    if /I "%%~A"=="vs2022" set "GENERATOR=vs2022"
    if /I "%%~A"=="vs2026" set "GENERATOR=vs2026"
    if /I "%%~A"=="--no-open" set "OPEN_SOLUTION=0"
)

rem Resolve the repository root from the batch file location, not the caller's CWD.
pushd "%~dp0..\.."
if errorlevel 1 goto :cannot_enter_repo
set "ROOT=%CD%"
set "TOOLS_DIR=%ROOT%\build\build"
set "PROJECTS_DIR=%ROOT%\proj"
set "BIN_DIR=%ROOT%\build\bin"
set "OBJ_DIR=%ROOT%\build\obj"
set "SRC_DIR=%ROOT%\src"
set "PREMAKE=%TOOLS_DIR%\premake5.exe"
set "PREMAKE_LUA=%TOOLS_DIR%\premake5.lua"

if /I not "%~dp0"=="%TOOLS_DIR%\" goto :wrong_location
if not exist "%PREMAKE_LUA%" goto :missing_lua

color 0D
title BeyondMain - Project Forge v9
echo.
echo    +====================================================================+
echo    ^|                         B E Y O N D M A I N                      ^|
echo    ^|                       P R O J E C T   F O R G E                ^|
echo    +====================================================================+
color 0B
echo                       C++20 / PREMAKE 5 / VISUAL STUDIO
color 08
echo                         BUILD. BREAK. DEBUG. MASTER.
color 07
echo.
echo    REPO:     "%ROOT%"
echo    SOURCES:  "%SRC_DIR%"
echo    PROJECTS: "%PROJECTS_DIR%"
echo.

color 0B
echo    [1/4] Preparing generated-output folders...
for %%D in (
    "%PROJECTS_DIR%"
    "%BIN_DIR%"
    "%OBJ_DIR%"
) do (
    if not exist "%%~D\" (
        mkdir "%%~D" >nul 2>&1
        if errorlevel 1 goto :directory_error
    )
)
color 0A
echo    [OK] Project files: proj\
echo    [OK] Executables:  build\bin\
echo    [OK] Object files: build\obj\
echo.

color 0B
echo    [2/4] Verifying source directory...
if not exist "%SRC_DIR%\" goto :source_missing
color 0A
echo    [OK] src\ is user-managed. No folders or placeholders will be created.
echo.

color 0B
echo    [3/4] Checking Premake and Visual Studio generator...
rem Accommodate an older installation that left premake5.exe at repo root.
if not exist "%PREMAKE%" if exist "%ROOT%\premake5.exe" (
    move /Y "%ROOT%\premake5.exe" "%PREMAKE%" >nul
    if errorlevel 1 goto :premake_move_error
)
if not exist "%PREMAKE%" if exist "%ROOT%\build\premake5.exe" (
    move /Y "%ROOT%\build\premake5.exe" "%PREMAKE%" >nul
    if errorlevel 1 goto :premake_move_error
)
if not exist "%PREMAKE%" goto :premake_missing

if /I "%GENERATOR%"=="vs2026" (
    "%PREMAKE%" --help 2>nul | findstr /I /C:"vs2026" >nul
    if errorlevel 1 (
        color 0E
        echo    [INFO] vs2026 unavailable. Falling back to vs2022.
        set "GENERATOR=vs2022"
    )
)
"%PREMAKE%" --help 2>nul | findstr /I /C:"%GENERATOR%" >nul
if errorlevel 1 goto :generator_missing
color 0A
echo    [OK] Using %GENERATOR% and "%PREMAKE%"
echo.

color 0B
echo    [4/4] Generating solution from the current src\ contents...
"%PREMAKE%" --file="%PREMAKE_LUA%" %GENERATOR%
if errorlevel 1 goto :generation_error

set "SOLUTION="
if exist "%PROJECTS_DIR%\BeyondMain.slnx" set "SOLUTION=%PROJECTS_DIR%\BeyondMain.slnx"
if not defined SOLUTION if exist "%PROJECTS_DIR%\BeyondMain.sln" set "SOLUTION=%PROJECTS_DIR%\BeyondMain.sln"
if not defined SOLUTION goto :solution_missing
if not exist "%PROJECTS_DIR%\BeyondMain.vcxproj" goto :project_missing

color 0A
echo.
echo    +====================================================================+
echo    ^|                 PROJECT FORGE - SUCCESS                        ^|
echo    +====================================================================+
color 07
echo    Solution: "%SOLUTION%"
echo    Binaries: "%BIN_DIR%\Debug-x64" / "Release-x64"
echo    Objects:  "%OBJ_DIR%\Debug-x64" / "Release-x64"
echo    Source:   "%SRC_DIR%" ^(unchanged^)
echo.

if "%OPEN_SOLUTION%"=="0" goto :success
color 0D
echo    [LAUNCH] Opening Visual Studio solution...
start "" "%SOLUTION%"
goto :success

:wrong_location
color 0C
echo    [ERROR] This script must live in repo\build\build\.
goto :failure

:missing_lua
color 0C
echo    [ERROR] Missing "%PREMAKE_LUA%".
goto :failure

:directory_error
color 0C
echo    [ERROR] Couldn't create generated-output folders.
goto :failure

:source_missing
color 0C
echo    [ERROR] Missing "%SRC_DIR%". Create your src folder manually.
goto :failure

:premake_move_error
color 0C
echo    [ERROR] Couldn't move premake5.exe into build\build\.
goto :failure

:premake_missing
color 0C
echo    [ERROR] Missing "%PREMAKE%". Put premake5.exe in build\build\.
goto :failure

:generator_missing
color 0C
echo    [ERROR] Premake does not support %GENERATOR%.
goto :failure

:generation_error
color 0C
echo    [ERROR] Premake failed. See the error messages above.
goto :failure

:solution_missing
color 0C
echo    [ERROR] No BeyondMain.slnx or BeyondMain.sln in proj\.
goto :failure

:project_missing
color 0C
echo    [ERROR] Missing proj\BeyondMain.vcxproj.
goto :failure

:cannot_enter_repo
color 0C
echo    [ERROR] Can't access repository root two levels above this script.
color 07
pause
exit /b 1

:failure
color 0C
echo.
echo    [FAILED] No source files or folders were changed.
color 07
pause
popd
exit /b 1

:success
color 0A
echo    [DONE] Add, rename, or delete folders under src\ freely.
echo           Rerun this script to refresh Visual Studio projects.
color 07
pause
popd
exit /b 0
