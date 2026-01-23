#!/bin/bash
# DarkFi Testnet - Install Dependencies
# Installs Rust, system libraries, and OpenCL for AMD GPU mining

set -e

echo "=== DarkFi Dependency Installation ==="

# Install Rust if not present or update if present
if command -v rustup &> /dev/null; then
    echo "[*] Updating Rust..."
    rustup update stable
else
    echo "[*] Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Add wasm32 target for DarkFi
echo "[*] Adding wasm32-unknown-unknown target..."
rustup target add wasm32-unknown-unknown

# Verify Rust version
RUST_VERSION=$(rustc --version | cut -d' ' -f2)
echo "[*] Rust version: $RUST_VERSION"

# Install system dependencies
echo "[*] Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    git \
    cmake \
    make \
    gcc \
    g++ \
    pkg-config \
    libasound2-dev \
    libclang-dev \
    libfontconfig1-dev \
    libhwloc-dev \
    liblzma-dev \
    libssl-dev \
    libsqlcipher-dev \
    libsqlite3-dev \
    libuv1-dev \
    jq

# Install AMD GPU / OpenCL dependencies
echo "[*] Installing OpenCL dependencies for AMD GPU..."
sudo apt-get install -y \
    ocl-icd-opencl-dev \
    mesa-opencl-icd \
    clinfo

# Verify OpenCL setup
echo ""
echo "=== OpenCL Device Information ==="
clinfo --list || echo "[!] No OpenCL devices found. Check AMD driver installation."

echo ""
echo "=== Dependencies installed successfully ==="
echo "Rust version: $(rustc --version)"
echo "Cargo version: $(cargo --version)"
