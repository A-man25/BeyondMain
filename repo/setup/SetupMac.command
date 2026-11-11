#!/bin/bash
# Double-click on macOS or run from Terminal. No hardcoded home-folder paths.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
/bin/bash "$SCRIPT_DIR/Mac/setup.sh"
