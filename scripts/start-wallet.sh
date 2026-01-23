#!/bin/bash
# DarkFi Testnet - Start drk Wallet (Interactive Mode)

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DARKFI_DIR="$REPO_DIR/darkfi"

echo "=== Starting DarkFi Wallet ==="

# Check binary exists
if [ ! -f "$DARKFI_DIR/drk" ]; then
    echo "[✗] drk not found. Run 02-build-darkfi.sh first."
    exit 1
fi

# Subscribe to blockchain and scan
echo "[*] Subscribing to blockchain..."
"$DARKFI_DIR/drk" subscribe

echo "[*] Scanning blockchain..."
"$DARKFI_DIR/drk" scan

echo ""
echo "=== Wallet Commands ==="
echo "Check balance:    $DARKFI_DIR/drk wallet --balance"
echo "Show address:     $DARKFI_DIR/drk wallet --address"
echo "Transfer:         $DARKFI_DIR/drk transfer <amount> <address>"
echo ""

# Start interactive mode
echo "[*] Starting interactive mode..."
"$DARKFI_DIR/drk"
