# OWS - Open Wallet Standard

Local-first, multi-chain wallet management for AI agents. By MoonPay.

- Website: https://openwallet.sh
- GitHub: https://github.com/open-wallet-standard/core
- npm: https://www.npmjs.com/package/@open-wallet-standard/core

## When to Use

- Checking wallet balances
- Signing transactions or messages (EVM, Solana, Bitcoin, Cosmos, etc.)
- Making x402 payments to paid APIs
- Creating and managing agent wallets

## Install

```bash
npm install -g @open-wallet-standard/core
```

## CLI Reference

```bash
# Wallet management
ows wallet create --name <name>    # Create new wallet (all chains derived automatically)
ows wallet list                    # List all wallets
ows wallet info                    # Show vault path + supported chains

# Balances
ows fund balance --wallet <name> --chain <chain>   # Check balance (base, ethereum, solana, etc.)
ows fund deposit --wallet <name> --chain <chain>    # Get deposit link

# Signing
ows sign message --wallet <name> --chain <chain> --message <msg>
ows sign tx --wallet <name> --chain <chain> --tx <hex>

# x402 payments
ows pay request --wallet <name> <url>       # Pay an x402-enabled API
ows pay discover <url>                       # Discover x402 services
```

## Node.js SDK

```typescript
import { createWallet, signMessage } from "@open-wallet-standard/core";

const wallet = createWallet("my-wallet");
const sig = signMessage("my-wallet", "evm", "hello");
```

## Supported Chains

EVM (Ethereum, Base, Polygon, Arbitrum), Solana, Bitcoin, Cosmos, Tron, TON, Sui, Filecoin, Spark. All derived from a single BIP-39 seed via CAIP-2 chain identifiers.

## Security Model

- Keys encrypted at rest (AES-256-GCM) in `~/.ows/wallets/`
- Keys decrypted only during signing, wiped from memory immediately after
- Pre-signing policy engine for spending limits and chain allowlists
- The OWS API never returns raw private keys
- Append-only audit log at `~/.ows/logs/audit.jsonl`

## Important

- Never ask for or handle raw private keys. OWS signs internally.
- See the full docs at https://openwallet.sh for policy engine and advanced usage.
