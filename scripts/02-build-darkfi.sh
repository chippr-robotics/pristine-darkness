#!/bin/bash
# DarkFi Testnet - Build DarkFi (darkfid and drk)

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DARKFI_DIR="$REPO_DIR/darkfi"
DARKFI_REPO="https://codeberg.org/darkrenaissance/darkfi.git"
DARKFI_VERSION="master"

echo "=== Building DarkFi ==="

# Source cargo env if needed
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Clone repository if not present
if [ ! -d "$DARKFI_DIR" ]; then
    echo "[*] Cloning DarkFi repository..."
    git clone "$DARKFI_REPO" "$DARKFI_DIR"
fi

cd "$DARKFI_DIR"

# Fetch and checkout version
echo "[*] Checking out $DARKFI_VERSION..."
git fetch --all --tags
git checkout "origin/$DARKFI_VERSION"

# Build darkfid and drk
echo "[*] Building darkfid..."
make darkfid

echo "[*] Building drk..."
make drk

# Verify binaries
echo ""
echo "=== Build Complete ==="
if [ -f "$DARKFI_DIR/darkfid" ]; then
    echo "[✓] darkfid binary: $DARKFI_DIR/darkfid"
else
    echo "[✗] darkfid binary not found!"
    exit 1
fi

if [ -f "$DARKFI_DIR/drk" ]; then
    echo "[✓] drk binary: $DARKFI_DIR/drk"
else
    echo "[✗] drk binary not found!"
    exit 1
fi

echo ""
echo "Add to PATH (optional):"
echo "  export PATH=\"$DARKFI_DIR:\$PATH\""
