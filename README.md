# 🌊 FlowStream — Decentralized Payment Streaming Protocol

**FlowStream** is a proof-of-concept (POC) for a decentralized payment streaming platform built on Ethereum. It enables continuous, per-second token transfers between addresses — unlocking real-time payroll, subscription billing, and vesting schedules on-chain.

## How It Works

### The Concept

Traditional payments are discrete: you send a lump sum and it arrives at once. **Payment streaming** turns this model on its head — tokens flow continuously from sender to recipient every second, creating a real-time money flow.

```
Sender ───── 0.27 USDC/sec ─────► Recipient
             ▲                     │
             │ deposit locked      │ withdraw anytime
             │ in contract         │ up to earned amount
```

### Key Flows

1. **Create Stream** — Sender deposits ERC-20 tokens into the contract, specifying recipient, start time, end time, and total amount. Tokens are locked and streamed at a constant rate.

2. **Withdraw** — Recipient can withdraw accrued tokens at any time. The available balance increases every second based on the rate.

3. **Cancel Stream** — Either party can cancel. The contract calculates the pro-rata split: earned tokens go to the recipient, remaining tokens are refunded to the sender.

### DeFi Payment Solutions Context

FlowStream addresses several real-world DeFi use cases:

- **Payroll Streaming**: Pay employees continuously instead of bi-weekly, improving cash flow for both parties
- **Subscription Payments**: SaaS services can charge per-second, with users able to cancel anytime
- **Token Vesting**: Distribute tokens to team members with linear unlock schedules
- **Service Payments**: Pay freelancers and contractors as work is performed
- **DAO Treasury**: Stream funds to contributors with transparent on-chain accounting

Similar protocols in production include **Sablier**, **Superfluid**, and **Llamapay**.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend (React)                      │
│  Dashboard • Stream List • Stats • Real-time Progress        │
└──────────────────────────┬──────────────────────────────────┘
                           │ REST API
┌──────────────────────────┴──────────────────────────────────┐
│                     Backend (Go + Gin)                        │
│  Event Indexer • REST API • Stream State Management          │
└──────────────────────────┬──────────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              │                         │
┌─────────────┴──────────┐  ┌──────────┴──────────────┐
│     PostgreSQL          │  │    Ethereum (EVM)        │
│  Stream records         │  │  FlowStream.sol          │
│  Event history          │  │  ERC-20 token lock       │
│  Indexer state          │  │  Per-second streaming    │
└────────────────────────┘  └─────────────────────────┘
```

## Project Structure

```
flowstream-defi-poc-build/
├── contracts/                 # Solidity smart contracts (Foundry)
│   ├── src/
│   │   ├── FlowStream.sol     # Core streaming contract
│   │   ├── MockERC20.sol      # Test token
│   │   ├── interfaces/        # IERC20 interface
│   │   └── utils/             # ReentrancyGuard
│   ├── test/
│   │   └── FlowStream.t.sol   # Comprehensive Foundry tests (17 tests)
│   ├── script/
│   │   └── Deploy.s.sol       # Deployment script
│   └── foundry.toml
├── backend/                   # Go event indexer + API server
│   ├── cmd/indexer/main.go    # Entry point
│   ├── internal/
│   │   ├── config/            # Environment configuration
│   │   ├── db/                # PostgreSQL data layer
│   │   ├── handlers/          # HTTP API handlers
│   │   ├── indexer/           # Blockchain event indexer
│   │   └── models/            # Data models
│   ├── Dockerfile
│   └── go.mod
├── frontend/                  # React dashboard
│   ├── src/
│   │   ├── components/        # StatsCards, StreamTable, StreamDetail, FilterBar
│   │   ├── hooks/             # useStreams custom hook
│   │   ├── types/             # TypeScript type definitions
│   │   └── utils/             # API client, formatting helpers
│   └── package.json
├── database/
│   └── schema.sql             # PostgreSQL schema
├── docker-compose.yml         # Full stack orchestration
└── README.md
