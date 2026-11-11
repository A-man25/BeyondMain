
#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
TOOLS="$ROOT/build/build"

echo ""
echo "========================================="
echo "       BEYONDMAIN - macOS LAUNCHER"
echo "========================================="
echo ""

# Check Apple developer tools
if ! xcode-select -p >/dev/null 2>&1; then
    echo "[ERROR] Apple Command Line Tools required."
    echo "Run: xcode-select --install"
    exit 1
fi

# Locate Premake
if command -v premake5 >/dev/null 2>&1; then
    PREMAKE="$(command -v premake5)"
elif [ -x "$TOOLS/premake5" ]; then
    PREMAKE="$TOOLS/premake5"
else
    echo "[ERROR] Premake 5 not found."
    echo "Install Premake for macOS."
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo "[ERROR] GNU Make is required."
    exit 1
fi

echo "[1/4] Generating Makefiles..."

cd "$TOOLS"
"$PREMAKE" gmake2

echo "[2/4] Locating generated Makefile..."

# Premake's output location is defined in premake5.lua
if [ -f "$ROOT/proj/Makefile" ]; then
    BUILD_DIR="$ROOT/proj"
elif [ -f "$TOOLS/Makefile" ]; then
    BUILD_DIR="$TOOLS"
else
    echo "[ERROR] Could not find generated Makefile."
    exit 1
fi

echo "[3/4] Building Debug configuration..."

make -C "$BUILD_DIR" config=debug -j 4

echo "[4/4] Launching VS Code..."

if ! command -v code >/dev/null 2>&1; then
    echo "[ERROR] VS Code CLI not found."
    echo "In VS Code, install the 'code' shell command."
    exit 1
fi

code --install-extension ms-vscode.cpptools --force
code --install-extension vadimcn.vscode-lldb --force

echo "[SUCCESS] BeyondMain ready."
code "$ROOT"
