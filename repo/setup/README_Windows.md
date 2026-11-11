# BeyondMain — Windows setup & launch

## For a fresh clone

**Requirements:** Windows 10/11 x64, an internet connection for first-time tool installation, sufficient disk space, and permission to install developer tools. VS Code may already be installed; otherwise the setup offers to install it.

1. Clone the repo and extract `Setup.zip`, `.vscode.zip` and `Launcher.zip` **into the `repo/` root** (not nested into extra ZIP-named folders).
2. Confirm `repo/build/build/premake5.lua` exists and `repo/src/` contains source files.
3. Double-click **`repo/Setup/SetupWindows.bat`** (or launch it in CMD). Accept the option to install Visual Studio Build Tools if needed; it may request administrator approval. VS Code will be installed via `winget` if absent and you approve.
4. Setup automatically locates Visual Studio 2022/2026, downloads a verified official Premake executable if no compatible one exists, generates the `.sln` or `.slnx` under `proj/`, builds Debug x64, installs the Microsoft C/C++ VS Code extension and opens the `repo/` folder in VS Code.
5. If an installer requests a restart, restart and rerun the same batch file. The operation is designed to be repeatable.

**Why this fixes the earlier error:** VS Code calls a saved `.ps1` file and passes paths as arguments. It does *not* inline an unquoted `C:\Program Files (x86)` into PowerShell, so spaces and parentheses are safe.

## Every day

- **Open VS Code + check/build:** double-click `Launcher/LaunchVSCodeWindows.bat`.
- **Build Debug:** press `Ctrl+Shift+B` in VS Code (or select `Terminal > Run Build Task > BeyondMain | Build Debug`).
- **Build Release:** `Terminal > Run Task > BeyondMain | Build Release`.
- **Regenerate after Premake changes:** `Terminal > Run Task > BeyondMain | Regenerate Projects`.
- **Debug:** choose `BeyondMain | Windows MSVC Debug` under Run and Debug, then press `F5`. Set breakpoints with `F9`.
- **Open full Visual Studio IDE, if installed:** double-click `Launcher/LaunchVisualStudioWindows.bat`.

The tasks do **not** depend on `msbuild` being on your `PATH`, a fixed Visual Studio edition/year, your username, or the clone location.

## Prerequisites and installer behavior

The build requires MSBuild, the MSVC C++ compiler and a Windows SDK. If a Visual Studio installation has only the IDE without the C++ workload, the setup treats those C++ Build Tools as missing and offers to install them via `winget` (a large download). Company-managed machines may block `winget`, elevation or downloads; install Visual Studio Build Tools manually and select **Desktop development with C++**, then rerun.

- Visual Studio Build Tools: https://visualstudio.microsoft.com/downloads/
- VS Code: https://code.visualstudio.com/
- Premake: https://premake.github.io/download/

The setup fetches the official Premake v5.0.0 Windows release only when necessary and checks its SHA-256 before extracting it. Downloaded tools and build artifacts are local to `.beyondmain/` and `build/`.

## Troubleshooting

**`BeyondMain.slnx` not found:** confirm `build/build/premake5.lua` and the Premake output location. This bundle expects generated projects in `repo/proj/`. The generator prints a specific error if it uses a different location or name.

**C++ toolset not installed / SDK missing:** use Visual Studio Installer to add `Desktop development with C++` and a Windows SDK, then rerun.

**Debugger cannot find `.exe`:** the known Windows target is `repo/build/bin/Debug-x64/BeyondMain.exe`. If your Premake `targetdir` differs, edit the `program` path in `.vscode/launch.json`.

**VS Code terminal says `msbuild` not recognized:** use the bundled `tasks.json`, not a hand-written task calling `msbuild` by name.

**Project compiles in Visual Studio but not on Mac:** see `README_Mac.md` for platform-specific source compatibility.

## Committing to Git

Commit `Setup/`, `Launcher/` and `.vscode/` as text files. You can normally ignore `.beyondmain/`, build binaries and generated `proj/` files. **Do not ignore `build/build/premake5.lua` or required source/dependency files.** If the repo depends on Git submodules, clone with `--recurse-submodules` or run `git submodule update --init --recursive` first.
