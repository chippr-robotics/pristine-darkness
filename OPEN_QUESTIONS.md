# DarkFi Open Questions & Notes

## Status (Updated 2026-01-23)
- **darkirc**: Working, connected to network (commit a05956d)
- **darkfid**: WAITING - testnet offline, pending reset
- **Mining**: WAITING - depends on darkfid
- **localnet**: Not tested (testnet is priority)

## RESOLVED: Testnet Status

**Asked in #dev as zk99:**
> hey, trying to run a testnet node on a05956d but getting genesis errors. is testnet working right now or should i wait for the reset?

**Response from upgrayedd:**
> zk99: wait for the reset

**Confirmed by ryu:**
> ++

**Conclusion:** Testnet is intentionally offline. Wait for network reset.

## Timeline
- No specific timeline provided
- Active development ongoing (commits to master daily)
- Reset is planned but no ETA

## Action Items
1. [x] Asked about testnet status in #dev
2. [ ] Monitor #dev for reset announcement
3. [ ] Re-test darkfid after reset announced
4. [ ] Test mining after node syncs

## Technical Notes (for after reset)
- Use commit recommended by devs (currently a05956d, may change)
- Config: tcp+tls transport preferred over tor (faster)
- Seeds: lilith0/lilith1.dark.fi (ports TBD after reset)
- darkirc seeds work on port 25551

## Applied from #dev Chat

- tor+tls is outgoing only - no need for tor+tls listener (Tor already encrypted) - from grug
- Recent commits: explorer search pages, DAO rename/removal functionality

## Observations

- TCP seeds (lilith0/lilith1.dark.fi:18340) refusing connections for darkfid
- darkirc TCP seeds (port 25551) also refused but found peers via other nodes
- Tor .onion seeds timing out for darkfid

## Next Steps

1. Rebuild darkfid on commit a05956d
2. Check if darkirc config seeds work for darkfid
3. Test node sync
4. Test mining once synced

## Notes from Conversations

### Contract Deployment Bug (ryu)
- Deterministic script reproduces error
- Deploying 10 different contracts with same wasm causes error
- Related to membership contract with merkle/smt

---
*Last updated: 2026-01-23*
