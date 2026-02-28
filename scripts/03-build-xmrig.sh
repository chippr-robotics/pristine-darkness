#!/bin/bash
# DarkFi Testnet - Build xmrig with OpenCL support

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

XMRIG_DIR="$REPO_DIR/xmrig"
XMRIG_REPO="https://github.com/xmrig/xmrig.git"

echo "=== Building xmrig with OpenCL ==="

# Clone repository if not present
if [ ! -d "$XMRIG_DIR" ]; then
    echo "[*] Cloning xmrig repository..."
    git clone --recursive "$XMRIG_REPO" "$XMRIG_DIR"
fi

cd "$XMRIG_DIR"

# Fetch tags and checkout latest stable (graceful failure)
echo "[*] Fetching latest release..."
if git fetch --all --tags 2>/dev/null; then
    echo "[✓] Fetch complete"
else
    echo "[!] Fetch failed -- proceeding with cached source"
fi
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
echo "[*] Checking out $LATEST_TAG..."
git checkout "$LATEST_TAG"
git submodule update --init --recursive

# Create build directory
mkdir -p build
cd build

# Configure with OpenCL enabled, CUDA disabled
echo "[*] Configuring cmake with OpenCL support..."
cmake .. \
    -DWITH_OPENCL=ON \
    -DWITH_CUDA=OFF \
    -DCMAKE_BUILD_TYPE=Release

# Build
echo "[*] Building xmrig..."
make -j$(nproc)

# Record the exact commit hash
BUILD_COMMIT=$(git rev-parse --short HEAD)

# Verify binary
echo ""
echo "=== Build Complete ==="
if [ -f "$XMRIG_DIR/build/xmrig" ]; then
    echo "[✓] xmrig binary: $XMRIG_DIR/build/xmrig"
    echo ""
    echo "Checking OpenCL support..."
    "$XMRIG_DIR/build/xmrig" --version

    # Record build result
    if [ -x "$SCRIPT_DIR/update-versions.sh" ]; then
        "$SCRIPT_DIR/update-versions.sh" --component xmrig --commit "$BUILD_COMMIT" --tag "$LATEST_TAG" --status success
    fi
else
    echo "[✗] xmrig binary not found!"
    if [ -x "$SCRIPT_DIR/update-versions.sh" ]; then
        "$SCRIPT_DIR/update-versions.sh" --component xmrig --commit "$BUILD_COMMIT" --tag "$LATEST_TAG" --status failed
    fi
    exit 1
fi
