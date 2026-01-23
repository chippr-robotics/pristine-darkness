#!/bin/bash
# DarkFi Testnet - Start darkfid Node

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DARKFI_DIR="$REPO_DIR/darkfi"
LOG_DIR="$REPO_DIR/logs"

mkdir -p "$LOG_DIR"

echo "=== Starting DarkFi Node ==="
echo "Log file: $LOG_DIR/darkfid.log"
echo "Press Ctrl+C to stop"
echo ""

# Check binary exists
if [ ! -f "$DARKFI_DIR/darkfid" ]; then
    echo "[✗] darkfid not found. Run 02-build-darkfi.sh first."
    exit 1
fi

# Start darkfid with logging
# Stratum RPC is enabled via config file
"$DARKFI_DIR/darkfid" -v 2>&1 | tee "$LOG_DIR/darkfid.log"
