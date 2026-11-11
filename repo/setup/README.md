# BeyondMain — portable workstation setup

Extract the three ZIP archives **into the root of the cloned repository**. After extraction you should have these **three folders** beside `src/`, `build/` and `proj/`:

```text
repo/
├── Setup/
│   ├── SetupWindows.bat
│   ├── SetupMac.command
│   ├── Windows/{Setup.ps1,Build.ps1}
│   ├── Mac/{setup.sh,build.sh}
│   ├── README_Windows.md
│   └── README_Mac.md
├── .vscode/{tasks.json,launch.json,c_cpp_properties.json,extensions.json,settings.json}
├── Launcher/{LaunchVSCodeWindows.bat,LaunchVSCodeMac.command,LaunchVisualStudioWindows.bat}
├── build/build/premake5.lua
├── src/
└── proj/                       # generated per machine
```

**Windows:** open `Setup/README_Windows.md` and double-click `Setup/SetupWindows.bat`.

**macOS:** open `Setup/README_Mac.md` and run `bash Setup/SetupMac.command` from Terminal, or double-click it once executable.

**VS Code:** `Ctrl+Shift+B` (Windows) / `Cmd+Shift+B` (Mac) builds Debug; choose the correct debug profile in Run and Debug, then F5.

> This setup installs or locates **toolchains** but cannot automatically make Windows-only C++ libraries or APIs compile on macOS. macOS support depends on platform filters and dependencies in your existing `build/build/premake5.lua`, which has not been provided for review. See the OS-specific READMEs.
