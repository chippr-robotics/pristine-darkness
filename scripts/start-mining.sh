#!/bin/bash
# DarkFi Testnet - Start xmrig Mining with AMD GPU

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

XMRIG_BIN="$REPO_DIR/xmrig/build/xmrig"
STRATUM_URL="127.0.0.1:18347"
CONFIG_DIR="$HOME/.config/darkfi"
THREADS="${MINING_THREADS:-0}"  # 0 = auto-detect

echo "=== Starting DarkFi Mining ==="

# Check xmrig exists
if [ ! -f "$XMRIG_BIN" ]; then
    echo "[✗] xmrig not found. Run 03-build-xmrig.sh first."
    exit 1
fi

# Get wallet address
WALLET_ADDRESS=""

# Check command line argument first
if [ -n "$1" ]; then
    WALLET_ADDRESS="$1"
# Then check saved address file
elif [ -f "$CONFIG_DIR/wallet_address.txt" ]; then
    WALLET_ADDRESS=$(cat "$CONFIG_DIR/wallet_address.txt")
# Finally prompt user
else
    echo "Enter your wallet address:"
    read -r WALLET_ADDRESS
fi

if [ -z "$WALLET_ADDRESS" ]; then
    echo "[✗] No wallet address provided."
    echo "Usage: $0 <wallet_address>"
    echo "   or: Run 04-init-wallet.sh to generate one"
    exit 1
fi

echo "[*] Stratum URL: $STRATUM_URL"
echo "[*] Wallet: $WALLET_ADDRESS"
echo "[*] OpenCL (GPU) mining enabled"
echo ""

# Start xmrig with OpenCL
# -o: stratum server
# -u: wallet address (user)
# --opencl: enable OpenCL backend
# -r: retry count on connection failure
# -R: retry pause in seconds
# --donate-level: donation percentage (0-100)
"$XMRIG_BIN" \
    --opencl \
    -o "$STRATUM_URL" \
    -u "$WALLET_ADDRESS" \
    -r 1000 \
    -R 20 \
    --donate-level 0 \
    -t "$THREADS"
