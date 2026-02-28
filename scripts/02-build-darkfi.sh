#!/bin/bash
# DarkFi Testnet - Build DarkFi (darkfid and drk)
#
# Usage: 02-build-darkfi.sh [COMMIT|TAG|BRANCH]
#   If no argument given, checks versions.json for pinned_commit,
#   then falls back to origin/master.

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DARKFI_DIR="$REPO_DIR/darkfi"
DARKFI_REPO="https://codeberg.org/darkrenaissance/darkfi.git"
VERSIONS_FILE="$REPO_DIR/versions.json"

echo "=== Building DarkFi ==="

# Source cargo env if needed
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Determine target version
TARGET_VERSION=""
if [ -n "$1" ]; then
    TARGET_VERSION="$1"
    echo "[*] Using version from argument: $TARGET_VERSION"
elif [ -f "$VERSIONS_FILE" ] && command -v jq &>/dev/null; then
    PINNED=$(jq -r '.darkfi.pinned_commit // empty' "$VERSIONS_FILE")
    if [ -n "$PINNED" ]; then
        TARGET_VERSION="$PINNED"
        echo "[*] Using pinned commit from versions.json: $TARGET_VERSION"
    fi
fi

if [ -z "$TARGET_VERSION" ]; then
    TARGET_VERSION="origin/master"
    echo "[*] Using default: $TARGET_VERSION"
fi

# Clone repository if not present
if [ ! -d "$DARKFI_DIR" ]; then
    echo "[*] Cloning DarkFi repository..."
    git clone "$DARKFI_REPO" "$DARKFI_DIR"
fi

cd "$DARKFI_DIR"

# Fetch latest (graceful failure)
echo "[*] Fetching latest from upstream..."
if git fetch --all --tags 2>/dev/null; then
    echo "[✓] Fetch complete"
else
    echo "[!] Fetch failed -- proceeding with cached source"
fi

# Checkout target version
echo "[*] Checking out $TARGET_VERSION..."
git checkout "$TARGET_VERSION"

# Record the exact commit hash being built
BUILD_COMMIT=$(git rev-parse --short HEAD)
echo "[*] Building commit: $BUILD_COMMIT ($(git log -1 --format='%s' HEAD))"

# Build darkfid and drk
echo "[*] Building darkfid..."
make darkfid

echo "[*] Building drk..."
make drk

# Verify binaries
echo ""
echo "=== Build Complete ==="
BUILD_OK=true

if [ -f "$DARKFI_DIR/darkfid" ]; then
    echo "[✓] darkfid binary: $DARKFI_DIR/darkfid"
else
    echo "[✗] darkfid binary not found!"
    BUILD_OK=false
fi

if [ -f "$DARKFI_DIR/drk" ]; then
    echo "[✓] drk binary: $DARKFI_DIR/drk"
else
    echo "[✗] drk binary not found!"
    BUILD_OK=false
fi

# Record build result
if [ -x "$SCRIPT_DIR/update-versions.sh" ]; then
    if $BUILD_OK; then
        "$SCRIPT_DIR/update-versions.sh" --component darkfi --commit "$BUILD_COMMIT" --status success
    else
        "$SCRIPT_DIR/update-versions.sh" --component darkfi --commit "$BUILD_COMMIT" --status failed
    fi
fi

if ! $BUILD_OK; then
    exit 1
fi

echo ""
echo "Add to PATH (optional):"
echo "  export PATH=\"$DARKFI_DIR:\$PATH\""
