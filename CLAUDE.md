# DarkFi Testnet Setup

> **STATUS (2026-01-23):** Testnet is currently offline pending a network reset. The happy helpful robots at **ChipprBots** are monitoring #dev on darkirc for updates. Check back for reset announcement.
>
> - darkirc: Working (commit a05956d)
> - darkfid testnet: Waiting for reset
> - Contact: zk99 on darkirc #dev

This directory contains a complete DarkFi testnet environment with mining support for AMD GPUs.

## Quick Start

```bash
# 1. Install dependencies (run once)
./scripts/01-install-deps.sh

# 2. Build DarkFi (darkfid + drk)
./scripts/02-build-darkfi.sh

# 3. Build xmrig with OpenCL
./scripts/03-build-xmrig.sh

# 4. Initialize wallet
./scripts/04-init-wallet.sh

# 5. Start the node (Terminal 1)
./scripts/start-node.sh

# 6. Start the wallet (Terminal 2)
./scripts/start-wallet.sh

# 7. Start mining (Terminal 3)
./scripts/start-mining.sh

# Utility scripts
./scripts/update-darkfi.sh          # Check for upstream updates
./scripts/update-darkfi.sh --rebuild # Fetch and rebuild
./scripts/check-status.sh           # Diagnostics / connectivity check
```

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   xmrig     │────▶│   darkfid   │◀───▶│  DarkFi     │
│  (miner)    │     │   (node)    │     │  Network    │
└─────────────┘     └──────┬──────┘     └─────────────┘
    OpenCL              │
    (AMD GPU)           │ JSON-RPC
                   ┌────┴────┐
                   │   drk   │
                   │ (wallet)│
                   └─────────┘
```

- **darkfid**: Full node daemon that syncs with the DarkFi network
- **drk**: CLI wallet for managing keys, balances, and transactions
- **xmrig**: Mining software that connects via stratum RPC

## Directory Structure

```
pristine-darkness/
├── CLAUDE.md              # This file
├── versions.json          # Build version tracking
├── darkfi/                # DarkFi source and binaries
│   ├── darkfid            # Node binary
│   └── drk                # Wallet binary
├── xmrig/
│   └── build/xmrig        # Mining binary
├── scripts/               # Setup and run scripts
├── config/                # Config backups
└── logs/                  # Runtime logs
```

## Configuration Files

| Component | Config Location |
|-----------|----------------|
| darkfid   | `~/.config/darkfi/darkfid_config.toml` |
| drk       | `~/.config/darkfi/drk_config.toml` |
| wallet DB | `~/.local/share/darkfi/drk/wallet.db` |

### Key Config Settings

**darkfid_config.toml:**
```toml
network = "testnet"

[network_config."testnet".stratum_rpc]
rpc_listen = "tcp://127.0.0.1:18347"
```

**drk_config.toml:**
```toml
network = "testnet"
```

## Common Commands

### Node Operations
```bash
# Start node (foreground with logs)
./darkfi/darkfid -v

# Check if node is running
curl -s http://127.0.0.1:18345 -d '{"jsonrpc":"2.0","method":"ping","params":[],"id":1}'
```

### Wallet Operations
```bash
# Check balance
./darkfi/drk wallet --balance

# Show address
./darkfi/drk wallet --address

# Generate new keypair
./darkfi/drk wallet --keygen

# Subscribe to blockchain updates
./darkfi/drk subscribe

# Scan blockchain for transactions
./darkfi/drk scan

# Transfer tokens
./darkfi/drk transfer <amount> <recipient_address>
```

### Mining Operations
```bash
# Start mining with auto-detected wallet
./scripts/start-mining.sh

# Start mining with specific address
./scripts/start-mining.sh <wallet_address>

# Set thread count (0 = auto)
MINING_THREADS=4 ./scripts/start-mining.sh
```

## Troubleshooting

### Node won't sync
1. Check internet connectivity
2. Verify testnet peers are reachable
3. Check logs: `tail -f logs/darkfid.log`
4. Try removing blockchain data and resyncing:
   ```bash
   rm -rf ~/.local/share/darkfi/darkfid/testnet
   ```

### Wallet shows zero balance
1. Ensure node is fully synced ("Blockchain synced!" in logs)
2. Run `drk subscribe` to subscribe to updates
3. Run `drk scan` to scan for transactions
4. Wait for confirmations after mining

### Mining: "Connection refused"
1. Ensure darkfid is running
2. Verify stratum RPC is enabled in config
3. Check stratum port: `ss -tlnp | grep 18347`

### Mining: No OpenCL devices
1. Run `clinfo` to check GPU detection
2. Install AMD drivers: `sudo apt install mesa-opencl-icd`
3. For ROCm support: Install rocm-opencl-runtime

### Build fails
1. Check Rust version: `rustc --version` (need >= 1.77.0)
2. Ensure all deps installed: `./scripts/01-install-deps.sh`
3. Clean build: `cd darkfi && make clean && make darkfid drk`

## Network Ports

| Port  | Service | Protocol |
|-------|---------|----------|
| 18345 | darkfid RPC | JSON-RPC |
| 18346 | Management RPC | JSON-RPC |
| 18347 | Stratum RPC | Stratum |
| 28340 | P2P (testnet) | TCP |

## Monitoring

### Check Sync Status
```bash
# In drk
./darkfi/drk scan
# Shows current block height and sync progress
```

### Check Mining Hashrate
Hashrate is displayed in xmrig output:
- `speed`: Current hashrate (H/s)
- `accepted`: Shares accepted by pool
- `difficulty`: Current mining difficulty

### Check Balance
```bash
./darkfi/drk wallet --balance
```

## Security Notes

- Wallet database is encrypted with SQLCipher
- Default wallet password should be changed in `drk_config.toml`
- Keep wallet backups: `~/.local/share/darkfi/drk/wallet.db`
- Private keys never leave the wallet

## Resources

- [DarkFi Documentation](https://darkrenaissance.github.io/darkfi/)
- [DarkFi Repository](https://codeberg.org/darkrenaissance/darkfi)
- [xmrig Documentation](https://xmrig.com/docs)
