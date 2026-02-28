#!/bin/bash
# DarkFi Testnet - Update versions.json with build results
#
# Usage: update-versions.sh --component darkfi|xmrig --commit HASH --status success|failed
#        update-versions.sh --component xmrig --commit HASH --tag TAG --status success|failed

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
VERSIONS_FILE="$REPO_DIR/versions.json"

# Parse arguments
COMPONENT=""
COMMIT=""
TAG=""
STATUS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --component) COMPONENT="$2"; shift 2 ;;
        --commit)    COMMIT="$2"; shift 2 ;;
        --tag)       TAG="$2"; shift 2 ;;
        --status)    STATUS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -z "$COMPONENT" ] || [ -z "$COMMIT" ] || [ -z "$STATUS" ]; then
    echo "Usage: $0 --component darkfi|xmrig --commit HASH --status success|failed"
    exit 1
fi

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "[!] versions.json not found at $VERSIONS_FILE"
    exit 1
fi

DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

case "$COMPONENT" in
    darkfi)
        jq --arg commit "$COMMIT" \
           --arg date "$DATE" \
           --arg status "$STATUS" \
           '.darkfi.last_built_commit = $commit |
            .darkfi.last_built_date = $date |
            .darkfi.build_status = $status' \
           "$VERSIONS_FILE" > "$VERSIONS_FILE.tmp" && mv "$VERSIONS_FILE.tmp" "$VERSIONS_FILE"
        ;;
    xmrig)
        if [ -n "$TAG" ]; then
            jq --arg commit "$COMMIT" \
               --arg tag "$TAG" \
               --arg date "$DATE" \
               --arg status "$STATUS" \
               '.xmrig.last_built_commit = $commit |
                .xmrig.last_built_tag = $tag |
                .xmrig.last_built_date = $date |
                .xmrig.build_status = $status' \
               "$VERSIONS_FILE" > "$VERSIONS_FILE.tmp" && mv "$VERSIONS_FILE.tmp" "$VERSIONS_FILE"
        else
            jq --arg commit "$COMMIT" \
               --arg date "$DATE" \
               --arg status "$STATUS" \
               '.xmrig.last_built_commit = $commit |
                .xmrig.last_built_date = $date |
                .xmrig.build_status = $status' \
               "$VERSIONS_FILE" > "$VERSIONS_FILE.tmp" && mv "$VERSIONS_FILE.tmp" "$VERSIONS_FILE"
        fi
        ;;
    *)
        echo "[!] Unknown component: $COMPONENT (use darkfi or xmrig)"
        exit 1
        ;;
esac

echo "[✓] versions.json updated: $COMPONENT $STATUS ($COMMIT)"
