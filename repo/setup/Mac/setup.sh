#!/bin/bash
# BeyondMain | Self-setup for a fresh macOS development machine
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo ''
echo '=========================================='
echo '       BEYONDMAIN | macOS SETUP'
echo '=========================================='
echo "Repo: $ROOT"
echo ''

if [ "$(uname -s)" != 'Darwin' ]; then
    echo '[ERROR] This launcher is only for macOS.' >&2
    exit 1
fi

if ! xcrun --find clang++ >/dev/null 2>&1; then
    echo '[1/4] Requesting Apple Command Line Tools installation ...'
    xcode-select --install || true
    echo ''
    echo '[ACTION REQUIRED] Complete the macOS installer dialog, then run SetupMac.command again.'
    exit 2
fi
echo '[1/4] Apple Clang found.'

if ! command -v brew >/dev/null 2>&1; then
    for brewbin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brewbin" ]; then
            eval "$("$brewbin" shellenv)"
            break
        fi
    done
fi

if ! command -v premake5 >/dev/null 2>&1 && [ ! -x "$ROOT/build/build/premake5" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo '[2/4] Homebrew is needed to install Premake.'
        echo '        The standard Homebrew installer may request your macOS password.'
        if ! command -v curl >/dev/null 2>&1; then
            echo '[ERROR] curl is missing. Cannot download Homebrew.' >&2
            exit 1
        fi
        echo 'Installing Homebrew using the official installer from brew.sh ...'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        for brewbin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            if [ -x "$brewbin" ]; then
                eval "$("$brewbin" shellenv)"
                break
            fi
        done
    fi
    if ! command -v brew >/dev/null 2>&1; then
        echo '[ERROR] Homebrew install not detected. Visit https://brew.sh and rerun.' >&2
        exit 1
    fi
    echo '[2/4] Installing Premake using Homebrew ...'
    brew install premake
else
    echo '[2/4] Premake is available.'
fi

if [ -f "$ROOT/.gitmodules" ] && command -v git >/dev/null 2>&1; then
    echo '[BeyondMain] Initializing Git submodules ...'
    git -C "$ROOT" submodule update --init --recursive
fi

echo '[3/4] Generating and building BeyondMain ...'
/bin/bash "$SCRIPT_DIR/build.sh" Debug

echo '[4/4] Configuring VS Code ...'
CODE=''
if command -v code >/dev/null 2>&1; then
    CODE="$(command -v code)"
else
    for app in '/Applications/Visual Studio Code.app' "$HOME/Applications/Visual Studio Code.app"; do
        candidate="$app/Contents/Resources/app/bin/code"
        if [ -x "$candidate" ]; then
            CODE="$candidate"
            break
        fi
    done
fi

if [ -n "$CODE" ]; then
    "$CODE" --install-extension ms-vscode.cpptools --force || true
    "$CODE" --install-extension vadimcn.vscode-lldb --force || true
    "$CODE" "$ROOT"
else
    echo '[WARNING] VS Code command not found. Opening VS Code by application name.'
    echo '          If extensions are missing, install Microsoft C/C++ and CodeLLDB manually.'
    open -a 'Visual Studio Code' "$ROOT" || {
        echo '[ERROR] Visual Studio Code not installed. Install it from https://code.visualstudio.com/' >&2
        exit 1
    }
fi

echo '[SUCCESS] BeyondMain is ready. Use Build Debug and the macOS LLDB launch profile.'
