# BeyondMain — macOS setup & launch

## For a fresh clone

**Requirements:** a supported Intel or Apple Silicon Mac, VS Code installed (https://code.visualstudio.com/), an internet connection for first-time setup, and permission to install Apple developer tools/Homebrew packages.

1. Clone the repo and extract `Setup.zip`, `.vscode.zip` and `Launcher.zip` **into `repo/`**, next to `src/` and `build/`.
2. Open Terminal in `repo/`.
3. Run:
   ```bash
   chmod +x Setup/SetupMac.command Launcher/LaunchVSCodeMac.command
   bash Setup/SetupMac.command
   ```
4. If Apple Command Line Tools are missing, macOS opens a system installer dialog. Complete it and **run `bash Setup/SetupMac.command` again**. The script cannot silently accept Apple's installation prompts.
5. Setup detects Apple Clang, installs Homebrew (if needed for Premake), installs Premake via `brew install premake`, generates Makefiles with `gmake` or `gmake2`, builds the Debug configuration, installs the VS Code C/C++ and CodeLLDB extensions, and opens the repo.

The script uses standard Homebrew locations on Intel and Apple Silicon. It does not contain a user's home-directory path.

## Every day

- **Open/setup VS Code:** run `bash Launcher/LaunchVSCodeMac.command` or double-click it when executable.
- **Build Debug:** `Cmd+Shift+B` or `Terminal > Run Build Task` in VS Code.
- **Build Release:** `Terminal > Run Task > BeyondMain | Build Release`.
- **Regenerate:** `Terminal > Run Task > BeyondMain | Regenerate Projects`.
- **Debug:** select `BeyondMain | macOS LLDB Debug` in Run and Debug, then `F5`. CodeLLDB uses a generated symlink at `repo/.beyondmain/run/BeyondMain`, so it works with differing Debug output architecture folders.

## What the script **cannot** guarantee

Premake generates the build system, but **the actual C++ code must support macOS**. Windows-only APIs (`windows.h`, Win32, MFC, MSVC-only options, Windows PCH assumptions, Windows-specific libraries) require conditional compilation, replacements, or platform-specific Premake filters. A Makefile may generate successfully but compilation may still fail until the existing `premake5.lua` and sources are made portable.

This bundle expects:

- `repo/build/build/premake5.lua` as the Premake entry point.
- `repo/proj/Makefile` as its generated macOS Makefile.
- A built executable named `BeyondMain` somewhere under `repo/build/bin/`.
- A Debug configuration selectable by `make config=debug`.

If your actual Premake output differs, adjust `Setup/Mac/build.sh` after reviewing the script's error. The source project's Premake file was not supplied for verification, so these paths are based on the known Windows repository layout.

## Troubleshooting

**`xcrun: error` or `clang++` missing:** install the tools (`xcode-select --install`), finish the dialog, and run setup again. If you have full Xcode installed, accept its license if prompted.

**`brew` missing:** setup runs the official Homebrew installer. It may request your password or ask you to press Enter; these steps cannot be bypassed safely. See https://brew.sh/.

**Premake generates no Makefile in `proj`:** confirm that `build/build/premake5.lua` sets the expected `location` for its workspace and `gmake/gmake2` is supported.

**Compile errors mentioning Windows headers/libraries:** add macOS-specific source code or Premake filters. This is a code portability issue, not an installation error.

**VS Code F5 can't find the executable:** first run the Debug build successfully; then check that `.beyondmain/run/BeyondMain` points to your built binary.

**Extensions not installed:** install `ms-vscode.cpptools` and `vadimcn.vscode-lldb` in VS Code's Extensions view.

## Committing the files to Git

On a Mac, ensure launcher scripts have executable permissions when committed:

```bash
chmod +x Setup/SetupMac.command Launcher/LaunchVSCodeMac.command
chmod +x Setup/Mac/*.sh
git add Setup Launcher .vscode
```

Ignore generated `.beyondmain/` data, compiled binaries and other machine-local outputs. If using submodules, run `git submodule update --init --recursive` after cloning.
