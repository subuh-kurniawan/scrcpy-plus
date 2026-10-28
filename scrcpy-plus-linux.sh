#!/usr/bin/env bash
# ============================================================================
# scrcpy-plus v3 — Linux GUI & CLI Launcher
# Developer : Subuh Kurniawan <kurrniawansubuh@gmail.com>
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -gt 0 && "$1" != "--gui" ]]; then
  exec "$SCRIPT_DIR/scrcpy-plus" "$@"
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 belum terinstal. Install dengan: sudo apt install python3 python3-tk" >&2
  exit 1
fi

if ! python3 -c "import tkinter" >/dev/null 2>&1; then
  echo "Error: modul python3-tk belum terinstal." >&2
  echo "Ubuntu/Debian : sudo apt install python3-tk" >&2
  echo "Fedora/RHEL   : sudo dnf install python3-tkinter" >&2
  echo "Arch Linux    : sudo pacman -S tk" >&2
  exit 1
fi

exec python3 "$SCRIPT_DIR/scrcpy-plus-gui-crossplatform.py"
