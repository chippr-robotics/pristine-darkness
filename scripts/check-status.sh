#!/bin/bash
# DarkFi Testnet - Status Check / Diagnostics
#
# Reports: built versions, binary status, upstream delta, connectivity

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DARKFI_DIR="$REPO_DIR/darkfi"
XMRIG_DIR="$REPO_DIR/xmrig"
VERSIONS_FILE="$REPO_DIR/versions.json"

RPC_PORT=18345
MGMT_PORT=18346
STRATUM_PORT=18347

echo "=== DarkFi Testnet Status ==="
echo "Date: $(date -u +"%Y-%m-%d %H:%M UTC")"
echo ""

# --- versions.json ---
echo "--- Build Versions ---"
if [ -f "$VERSIONS_FILE" ] && command -v jq &>/dev/null; then
    DARKFI_COMMIT=$(jq -r '.darkfi.last_built_commit // "not built"' "$VERSIONS_FILE")
    DARKFI_DATE=$(jq -r '.darkfi.last_built_date // "n/a"' "$VERSIONS_FILE")
    DARKFI_STATUS=$(jq -r '.darkfi.build_status // "n/a"' "$VERSIONS_FILE")
    DARKFI_PINNED=$(jq -r '.darkfi.pinned_commit // "none"' "$VERSIONS_FILE")

    XMRIG_COMMIT=$(jq -r '.xmrig.last_built_commit // "not built"' "$VERSIONS_FILE")
    XMRIG_TAG=$(jq -r '.xmrig.last_built_tag // "n/a"' "$VERSIONS_FILE")
    XMRIG_DATE=$(jq -r '.xmrig.last_built_date // "n/a"' "$VERSIONS_FILE")
    XMRIG_STATUS=$(jq -r '.xmrig.build_status // "n/a"' "$VERSIONS_FILE")

    TESTNET_STATUS=$(jq -r '.testnet.status // "unknown"' "$VERSIONS_FILE")

    echo "darkfi:  $DARKFI_COMMIT ($DARKFI_STATUS) built $DARKFI_DATE"
    echo "         pinned: $DARKFI_PINNED"
    echo "xmrig:   $XMRIG_TAG $XMRIG_COMMIT ($XMRIG_STATUS) built $XMRIG_DATE"
    echo "testnet: $TESTNET_STATUS"
else
    echo "[!] versions.json not found or jq not installed"
fi

echo ""

# --- Binary check ---
echo "--- Binaries ---"
if [ -f "$DARKFI_DIR/darkfid" ]; then
    echo "[✓] darkfid: $DARKFI_DIR/darkfid"
else
    echo "[✗] darkfid: not found"
fi

if [ -f "$DARKFI_DIR/drk" ]; then
    echo "[✓] drk:     $DARKFI_DIR/drk"
else
    echo "[✗] drk:     not found"
fi

if [ -f "$XMRIG_DIR/build/xmrig" ]; then
    echo "[✓] xmrig:   $XMRIG_DIR/build/xmrig"
else
    echo "[✗] xmrig:   not found"
fi

echo ""

# --- Upstream delta ---
echo "--- Upstream Delta ---"
if [ -d "$DARKFI_DIR/.git" ]; then
    cd "$DARKFI_DIR"
    LOCAL_HEAD=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    echo "Local HEAD:     $LOCAL_HEAD"

    # Try to check upstream without fetching
    REMOTE_HEAD=$(git rev-parse --short origin/master 2>/dev/null || echo "unknown")
    echo "origin/master:  $REMOTE_HEAD"

    if [ "$LOCAL_HEAD" != "unknown" ] && [ "$REMOTE_HEAD" != "unknown" ]; then
        BEHIND=$(git rev-list --count HEAD..origin/master 2>/dev/null || echo "?")
        AHEAD=$(git rev-list --count origin/master..HEAD 2>/dev/null || echo "?")
        echo "Behind upstream: $BEHIND commits"
        echo "Ahead upstream:  $AHEAD commits"
    fi
    cd "$REPO_DIR"
else
    echo "[!] DarkFi repo not cloned"
fi

echo ""

# --- Connectivity ---
echo "--- Connectivity ---"

# darkfid RPC
printf "darkfid RPC (:%d):     " "$RPC_PORT"
if curl -s --max-time 3 "http://127.0.0.1:$RPC_PORT" \
    -d '{"jsonrpc":"2.0","method":"ping","params":[],"id":1}' \
    >/dev/null 2>&1; then
    echo "UP"
else
    echo "down"
fi

# Management RPC
printf "Management RPC (:%d): " "$MGMT_PORT"
if curl -s --max-time 3 "http://127.0.0.1:$MGMT_PORT" \
    -d '{"jsonrpc":"2.0","method":"ping","params":[],"id":1}' \
    >/dev/null 2>&1; then
    echo "UP"
else
    echo "down"
fi

# Stratum RPC
printf "Stratum RPC (:%d):    " "$STRATUM_PORT"
if ss -tlnp 2>/dev/null | grep -q ":$STRATUM_PORT " || \
   nc -z -w3 127.0.0.1 "$STRATUM_PORT" 2>/dev/null; then
    echo "UP"
else
    echo "down"
fi

# Seed nodes
echo ""
echo "--- Seed Nodes ---"
for SEED in lilith0.dark.fi lilith1.dark.fi; do
    printf "%-25s " "$SEED:28340"
    if nc -z -w5 "$SEED" 28340 2>/dev/null; then
        echo "reachable"
    else
        echo "unreachable"
    fi
done

echo ""
echo "=== End Status ==="
