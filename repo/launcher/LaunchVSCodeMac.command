#!/bin/bash
set -e
LAUNCHER_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$LAUNCHER_DIR/.." && pwd)"
if [ ! -f "$ROOT/setup/SetupMac.command" ]; then
    echo '[ERROR] setup/SetupMac.command missing. Extract setup.zip at repo root.' >&2
    exit 1
fi
/bin/bash "$ROOT/setup/SetupMac.command"
