#!/bin/bash
# DarkFi Testnet - Initialize Wallet and Generate Keypair

set -e

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DARKFI_DIR="$REPO_DIR/darkfi"
CONFIG_DIR="$HOME/.config/darkfi"

echo "=== DarkFi Wallet Initialization ==="

# Source cargo env if needed
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Check binaries exist
if [ ! -f "$DARKFI_DIR/darkfid" ]; then
    echo "[✗] darkfid not found. Run 02-build-darkfi.sh first."
    exit 1
fi

if [ ! -f "$DARKFI_DIR/drk" ]; then
    echo "[✗] drk not found. Run 02-build-darkfi.sh first."
    exit 1
fi

# Generate darkfid config if not exists
DARKFID_CONFIG="$CONFIG_DIR/darkfid_config.toml"
if [ ! -f "$DARKFID_CONFIG" ]; then
    echo "[*] Generating darkfid config..."
    "$DARKFI_DIR/darkfid" --config "$DARKFID_CONFIG" &
    DARKFID_PID=$!
    sleep 3
    kill $DARKFID_PID 2>/dev/null || true
    sleep 1
fi

# Update darkfid config for testnet with stratum RPC
if [ -f "$DARKFID_CONFIG" ]; then
    echo "[*] Configuring darkfid for testnet..."

    # Set network to testnet
    sed -i 's/^network = .*/network = "testnet"/' "$DARKFID_CONFIG"

    # Enable stratum RPC for mining (add if not present)
    if ! grep -q 'stratum_rpc' "$DARKFID_CONFIG"; then
        cat >> "$DARKFID_CONFIG" << 'EOF'

# Stratum RPC for mining
[network_config."testnet".stratum_rpc]
rpc_listen = "tcp://127.0.0.1:18347"
EOF
    fi
    echo "[✓] darkfid configured for testnet with stratum RPC"
fi

# Generate drk config if not exists
DRK_CONFIG="$CONFIG_DIR/drk_config.toml"
if [ ! -f "$DRK_CONFIG" ]; then
    echo "[*] Generating drk config..."
    echo "help" | "$DARKFI_DIR/drk" &
    DRK_PID=$!
    sleep 2
    kill $DRK_PID 2>/dev/null || true
    sleep 1
fi

# Update drk config for testnet
if [ -f "$DRK_CONFIG" ]; then
    echo "[*] Configuring drk for testnet..."
    sed -i 's/^network = .*/network = "testnet"/' "$DRK_CONFIG"
    echo "[✓] drk configured for testnet"
fi

# Initialize wallet database
echo "[*] Initializing wallet..."
"$DARKFI_DIR/drk" wallet --initialize

# Generate keypair
echo "[*] Generating keypair..."
"$DARKFI_DIR/drk" wallet --keygen

# Get and display wallet address
echo ""
echo "=== Wallet Initialized ==="
WALLET_ADDRESS=$("$DARKFI_DIR/drk" wallet --address)
echo "Your wallet address:"
echo "$WALLET_ADDRESS"

# Save address to file for mining script
echo "$WALLET_ADDRESS" > "$CONFIG_DIR/wallet_address.txt"
echo ""
echo "Address saved to: $CONFIG_DIR/wallet_address.txt"

# Backup configs
CONFIG_BACKUP="$REPO_DIR/config"
mkdir -p "$CONFIG_BACKUP"
cp "$DARKFID_CONFIG" "$CONFIG_BACKUP/" 2>/dev/null || true
cp "$DRK_CONFIG" "$CONFIG_BACKUP/" 2>/dev/null || true
echo "Config backups saved to: $CONFIG_BACKUP/"
