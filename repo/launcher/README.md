# BeyondMain launchers

These launchers live in `repo/Launcher/` and assume `repo/setup/` and `repo/.vscode/` exist.

- **Windows, VS Code:** double-click `LaunchVSCodeWindows.bat`. Runs idempotent setup, builds and opens the repo.
- **macOS, VS Code:** double-click `LaunchVSCodeMac.command` (or `bash Launcher/LaunchVSCodeMac.command`). Runs idempotent setup, builds and opens the repo.
- **Windows, Visual Studio:** double-click `LaunchVisualStudioWindows.bat`. Opens `proj/BeyondMain.slnx` or `.sln`, generating it if absent. Visual Studio IDE itself must be installed for this launcher (Build Tools alone are not an IDE).

The VS Code launchers intentionally rerun setup checks, so they can be used on fresh clones as well as previously configured machines.
