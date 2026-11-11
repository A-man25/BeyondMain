#!/bin/bash
# BeyondMain | macOS generation, build and clean (Apple Clang + GNU Make)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PREMAKE_HOME="$ROOT/build/build"
PROJ_DIR="$ROOT/proj"
BIN_BASE="$ROOT/build/bin"
MODE="${1:-Debug}"

if [ "$(uname -s)" != "Darwin" ]; then
    echo '[ERROR] This script requires macOS.' >&2
    exit 1
fi

if [ ! -f "$PREMAKE_HOME/premake5.lua" ]; then
    echo "[ERROR] Missing Premake script: $PREMAKE_HOME/premake5.lua" >&2
    exit 1
fi
if ! xcrun --find clang++ >/dev/null 2>&1; then
    echo '[ERROR] Apple Command Line Tools missing; run xcode-select --install and rerun SetupMac.command.' >&2
    exit 1
fi

# Support both default Homebrew installation locations, without guessing user paths.
for brewbin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if ! command -v brew >/dev/null 2>&1 && [ -x "$brewbin" ]; then
        eval "$("$brewbin" shellenv)"
    fi
done

if command -v premake5 >/dev/null 2>&1; then
    PREMAKE="$(command -v premake5)"
elif [ -x "$PREMAKE_HOME/premake5" ]; then
    PREMAKE="$PREMAKE_HOME/premake5"
else
    echo '[ERROR] Premake missing. Run Setup/SetupMac.command to install it.' >&2
    exit 1
fi
if ! command -v make >/dev/null 2>&1; then
    echo '[ERROR] make missing. Install Apple Command Line Tools.' >&2
    exit 1
fi

premake_help="$("$PREMAKE" --help 2>&1 || true)"
if printf '%s\n' "$premake_help" | grep -Eq '^[[:space:]]*gmake2([[:space:]]|$)'; then
    PREMAKE_ACTION=gmake2
elif printf '%s\n' "$premake_help" | grep -Eq '^[[:space:]]*gmake([[:space:]]|$)'; then
    PREMAKE_ACTION=gmake
else
    echo '[ERROR] Installed Premake has no gmake/gmake2 action.' >&2
    exit 1
fi

generate() {
    echo "[BeyondMain] Generating macOS Makefiles with $PREMAKE_ACTION ..."
    (cd "$PREMAKE_HOME" && "$PREMAKE" "$PREMAKE_ACTION")
    if [ ! -f "$PROJ_DIR/Makefile" ]; then
        echo "[ERROR] Expected $PROJ_DIR/Makefile; check Premake location settings." >&2
        exit 1
    fi
}

case "$MODE" in
    --generate) generate; exit 0 ;;
    --clean)
        if [ -f "$PROJ_DIR/Makefile" ]; then
            make -C "$PROJ_DIR" clean
        else
            echo '[BeyondMain] Nothing to clean (no Makefile).'
        fi
        exit 0 ;;
    Debug|Release) ;;
    *) echo 'Usage: build.sh [Debug|Release|--generate|--clean]' >&2; exit 2 ;;
esac

if [ ! -f "$PROJ_DIR/Makefile" ]; then
    generate
fi

config="$(printf '%s' "$MODE" | tr '[:upper:]' '[:lower:]')"
jobs="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
echo "[BeyondMain] Building $Mode with Apple Clang (config=$config) ..."
make -C "$PROJ_DIR" "config=$config" -j "$jobs"

# Stable, generated path for CodeLLDB: works even when targetdir differs by architecture.
if [ "$MODE" = Debug ]; then
    exe=""
    if [ -d "$BIN_BASE" ]; then
        exe="$(find "$BIN_BASE" -type f -name BeyondMain -path '*/Debug*/*' -print 2>/dev/null | head -n 1 || true)"
        if [ -z "$exe" ]; then
            exe="$(find "$BIN_BASE" -type f -name BeyondMain -print 2>/dev/null | head -n 1 || true)"
        fi
    fi
    if [ -z "$exe" ]; then
        echo '[ERROR] Build finished, but BeyondMain executable not found under build/bin.' >&2
        echo '        Confirm targetname and targetdir in premake5.lua.' >&2
        exit 1
    fi
    mkdir -p "$ROOT/.beyondmain/run"
    ln -sfn "$exe" "$ROOT/.beyondmain/run/BeyondMain"
    echo "[BeyondMain] LLDB target: $ROOT/.beyondmain/run/BeyondMain"
fi

echo '[BeyondMain] Build succeeded.'
