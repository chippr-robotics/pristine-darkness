# DarkFi Speedrun

Automation scripts for quickly setting up a DarkFi testnet node with GPU mining support.

## What's Included

| Script | Description |
|--------|-------------|
| `01-install-deps.sh` | Install Rust, OpenCL, and system dependencies |
| `02-build-darkfi.sh` | Clone and build DarkFi (darkfid + drk) |
| `03-build-xmrig.sh` | Clone and build xmrig with OpenCL support |
| `04-init-wallet.sh` | Initialize wallet, generate keys, configure testnet |
| `start-node.sh` | Start the DarkFi node daemon |
| `start-wallet.sh` | Start the wallet CLI |
| `start-mining.sh` | Start GPU mining |

## Prerequisites

- Ubuntu 22.04+ or Debian 12+
- 8GB+ RAM recommended
- AMD GPU (optional, for mining)
- Internet connection for syncing

## Quick Start

```bash
# Clone this repository
git clone https://github.com/chippr-robotics/darkfi-speedrun.git
cd darkfi-speedrun

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

After running the build scripts, your directory will look like:

```
darkfi-speedrun/
├── README.md              # This file
├── scripts/               # Setup and run scripts
├── config/                # Config backups
├── logs/                  # Runtime logs (created at runtime)
├── darkfi/                # DarkFi source and binaries (cloned by script)
│   ├── darkfid            # Node binary
│   └── drk                # Wallet binary
└── xmrig/                 # Mining software (cloned by script)
    └── build/xmrig        # Mining binary
```

## Configuration

### Config File Locations

| Component | Config Location |
|-----------|----------------|
| darkfid   | `~/.config/darkfi/darkfid_config.toml` |
| drk       | `~/.config/darkfi/drk_config.toml` |
| wallet DB | `~/.local/share/darkfi/drk/wallet.db` |

### Key Settings

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
curl -s http://127.0.0.1:8340 -d '{"jsonrpc":"2.0","method":"ping","params":[],"id":1}'
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

## Network Ports

| Port  | Service | Protocol |
|-------|---------|----------|
| 8340  | darkfid RPC | JSON-RPC |
| 18347 | Stratum RPC | Stratum |
| 26660 | P2P (testnet) | TCP |

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

## Security Notes

- Wallet database is encrypted with SQLCipher
- Default wallet password should be changed in `drk_config.toml`
- Keep wallet backups: `~/.local/share/darkfi/drk/wallet.db`
- Private keys never leave the wallet

## Resources

- [DarkFi Documentation](https://darkrenaissance.github.io/darkfi/)
- [DarkFi Repository](https://codeberg.org/darkrenaissance/darkfi)
- [xmrig Documentation](https://xmrig.com/docs)

## License

These scripts are provided as-is for educational and testing purposes. DarkFi and xmrig have their own respective licenses.
