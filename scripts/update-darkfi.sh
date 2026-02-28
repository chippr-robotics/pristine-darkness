#!/bin/bash
# DarkFi Testnet - Fetch latest upstream and show what's new
#
# Usage: update-darkfi.sh [--rebuild] [--pin COMMIT]
#   --rebuild    Rebuild after fetching
#   --pin COMMIT Pin versions.json to a specific commit

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DARKFI_DIR="$REPO_DIR/darkfi"
VERSIONS_FILE="$REPO_DIR/versions.json"

DO_REBUILD=false
PIN_COMMIT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --rebuild) DO_REBUILD=true; shift ;;
        --pin)     PIN_COMMIT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== DarkFi Update Check ==="

if [ ! -d "$DARKFI_DIR" ]; then
    echo "[!] DarkFi not cloned yet. Run 02-build-darkfi.sh first."
    exit 1
fi

cd "$DARKFI_DIR"

# Get current HEAD before fetch
OLD_HEAD=$(git rev-parse --short HEAD)

# Fetch latest
echo "[*] Fetching from upstream..."
if git fetch --all --tags 2>/dev/null; then
    echo "[✓] Fetch complete"
else
    echo "[!] Fetch failed"
    exit 1
fi

NEW_HEAD=$(git rev-parse --short origin/master)

# Show what's new since last build
LAST_BUILT=""
if [ -f "$VERSIONS_FILE" ] && command -v jq &>/dev/null; then
    LAST_BUILT=$(jq -r '.darkfi.last_built_commit // empty' "$VERSIONS_FILE")
fi

echo ""
if [ -n "$LAST_BUILT" ]; then
    echo "Last built commit: $LAST_BUILT"
    echo "Latest upstream:   $NEW_HEAD"

    # Count new commits
    LAST_FULL=$(git rev-parse "$LAST_BUILT" 2>/dev/null || echo "")
    if [ -n "$LAST_FULL" ]; then
        NEW_COMMITS=$(git rev-list --count "$LAST_FULL..origin/master" 2>/dev/null || echo "?")
        echo "New commits:       $NEW_COMMITS"

        if [ "$NEW_COMMITS" != "0" ] && [ "$NEW_COMMITS" != "?" ]; then
            echo ""
            echo "--- Recent commits ---"
            git log --oneline "$LAST_FULL..origin/master" | head -20
            if [ "$NEW_COMMITS" -gt 20 ] 2>/dev/null; then
                echo "... and $((NEW_COMMITS - 20)) more"
            fi
        else
            echo ""
            echo "[✓] Up to date"
        fi
    else
        echo "[!] Last built commit $LAST_BUILT not found in history"
        echo "    (may need a full rebuild)"
    fi
else
    echo "No previous build recorded."
    echo "Latest upstream: $NEW_HEAD"
fi

# Handle --pin
if [ -n "$PIN_COMMIT" ]; then
    echo ""
    echo "[*] Pinning versions.json to commit: $PIN_COMMIT"
    if [ -f "$VERSIONS_FILE" ] && command -v jq &>/dev/null; then
        jq --arg commit "$PIN_COMMIT" '.darkfi.pinned_commit = $commit' \
            "$VERSIONS_FILE" > "$VERSIONS_FILE.tmp" && mv "$VERSIONS_FILE.tmp" "$VERSIONS_FILE"
        echo "[✓] Pinned"
    else
        echo "[!] Cannot update versions.json (missing jq or file)"
    fi
fi

# Handle --rebuild
if $DO_REBUILD; then
    echo ""
    exec "$SCRIPT_DIR/02-build-darkfi.sh"
fi
