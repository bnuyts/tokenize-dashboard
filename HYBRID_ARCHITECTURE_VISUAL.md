# Hybrid Wallet Architecture - Visual Guide

## System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    TOKENIZE BANKING PLATFORM                        │
│                     (Compliance & Analytics Layer)                  │
└─────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      HYBRID GATEWAY CONTRACT                        │
│  - User Classification Engine                                       │
│  - Auto-Migration Triggers                                          │
│  - Compliance Enforcement Point                                     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
           ┌───────────────┴───────────────┐
           │                               │
           ▼                               ▼
┌──────────────────────┐      ┌──────────────────────────────┐
│  SEGREGATED          │      │  OMNIBUS POOL                │
│  WALLET SYSTEM       │      │  (Retail Users < $50K)       │
│  (High-Value >$50K)  │      │                              │
├──────────────────────┤      ├──────────────────────────────┤
│ Factory Contract     │      │ Shared Custody Contract      │
│ - Deploy ERC-4337    │      │ - Internal Ledger            │
│ - Configure Policies │      │ - Batch Processing           │
│ - Manage Upgrades    │      │ - Centralized Control        │
├──────────────────────┤      ├──────────────────────────────┤
│ Individual Wallets   │      │ User Balances:               │
│ ┌────────────────┐   │      │ • User A: $5,000            │
│ │ Wallet A       │   │      │ • User B: $12,000           │
│ │ (ERC-4337)     │   │      │ • User C: $8,000            │
│ │ Custom Policy  │   │      │                              │
│ └────────────────┘   │      │ External Assets:             │
│                      │      │ • USDC: $25,000              │
│ ┌────────────────┐   │      │ • ETH: 5 ETH                 │
│ │ Wallet B       │   │      └──────────────────────────────┘
│ │ (ERC-4337)     │   │
│ │ Enhanced Sec   │   │
│ └────────────────┘   │
└──────────────────────┘
           │                               │
           └───────────┬───────────────────┘
                       │
              ┌────────▼────────┐
              │ MIGRATION       │
              │ MANAGER         │
              │ - Auto-Upgrade  │
              │ - Downgrade     │
              │ - Notifications │
              └─────────────────┘
```

## User Journey: Retail to High-Value Migration

```
USER ONBOARDING
      │
      ▼
┌──────────────────┐
│ Register Account │
└──────────────────┘
      │
      ▼
┌──────────────────┐
│ KYC Verification │
└──────────────────┘
      │
      ▼
┌──────────────────┐
│ Initial Deposit  │
│ ($5,000)         │
└──────────────────┘
      │
      ▼
┌──────────────────┐
│ Assigned to      │
│ OMNIBUS POOL     │
│ (Retail Tier)    │
└──────────────────┘
      │
      │ User deposits more...
      │ Balance: $50,001
      ▼
┌──────────────────┐
│ AUTO-DETECTED    │
│ MIGRATION TRIGGER│
└──────────────────┘
      │
      ▼
┌──────────────────┐
│ Deploy Individual│
│ ERC-4337 Wallet  │
│ (High-Value Tier)│
└──────────────────┘
      │
      ▼
┌──────────────────┐
│ Transfer Assets  │
│ from Omnibus     │
└──────────────────┘
      │
      ▼
┌──────────────────┐
│ Enhanced Security│
│ Custom Policies  │
│ Active           │
└──────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                          │
└─────────────────────────────────────────────────────────────┘

OMNIBUS POOL SECURITY:
├─ Multi-Sig Treasury (5-of-7)
├─ 48-Hour Time Lock
├─ Emergency Pause
├─ Real-Time Monitoring
├─ Anomaly Detection
└─ Insurance Fund (1% TVL)

SEGREGATED WALLET SECURITY:
├─ Individual Security Policies
├─ Daily Spending Limits
├─ Whitelist Controls
├─ Social Recovery (3-of-5)
├─ Time-Locked Emergency Access
└─ Behavioral Biometrics

HYBRID GATEWAY SECURITY:
├─ Role-Based Access Control
├─ Compliance Verification
├─ Migration Validation
└─ Audit Trail Logging
```

## Transaction Flow Comparison

### Omnibus Pool (Retail)
```
User A Request → Gateway Check → Batch Queue → 
Multi-User Processing → Single Tx to External → 
Internal Ledger Update → User Notification
```
**Gas Cost:** ~50,000 gas per user (batched)  
**Time:** < 30 seconds

### Segregated Wallet (High-Value)
```
User B Request → Individual Validation → 
Security Policy Check → Signatures Required → 
Execute Transaction → Wallet State Update → 
Event Emission → User Notification
```
**Gas Cost:** ~200,000 gas per transaction  
**Time:** < 60 seconds

## Migration Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│              MIGRATION PROCESS (Omnibus → Segregated)       │
└─────────────────────────────────────────────────────────────┘

1. Threshold Detection
   └─ Balance > $50,000 USD
      └─ Trigger Classification Update

2. Eligibility Check
   └─ User not already migrating
   └─ KYC level sufficient
   └─ No pending withdrawals

3. Wallet Deployment
   └─ Generate unique salt
   └─ Deploy ERC-4337 wallet
   └─ Configure security policies
   └─ Set initial limits

4. Asset Transfer
   └─ Calculate omnibus balance
   └─ Initiate transfer to new wallet
   └─ Verify successful transfer
   └─ Update internal ledger

5. Classification Update
   └─ Mark as HIGH_VALUE tier
   └─ Disable migration flag
   └─ Emit MigrationCompleted event

6. User Notification
   └─ Email notification sent
   └─ In-app message displayed
   └─ Transaction receipt generated
```

## Compliance Integration Points

```
┌─────────────────────────────────────────────────────────────┐
│              COMPLIANCE GATEWAY INTEGRATION                 │
└─────────────────────────────────────────────────────────────┘

ONBOARDING FLOW:
User Registration → KYC Provider API → Verification Result → 
Classification Assignment → Wallet Type Selection

TRANSACTION MONITORING:
Transaction Request → Compliance Check → Risk Scoring → 
Approval/Rejection → Audit Log Entry → User Notification

REGULATORY REPORTING:
Daily Balance Aggregation → Transaction Pattern Analysis → 
Suspicious Activity Detection → Regulatory Report Generation → 
Submission to Authorities
```

## Performance Benchmarks

| Metric | Omnibus Pool | Segregated Wallets | Hybrid Average |
|--------|--------------|-------------------|----------------|
| **User Classification** | < 50ms | N/A | < 50ms |
| **Transaction Processing** | < 30s | < 60s | < 45s |
| **Gas Cost per User** | ~50K gas | ~200K gas | ~125K gas |
| **Migration Time** | N/A | N/A | < 5 min |
| **Max Users Supported** | 100,000+ | 10,000+ | 110,000+ |

## Risk Mitigation Strategies

### Omnibus Pool Risks
- **Single Point of Failure:** Multi-sig governance + insurance fund
- **Regulatory Classification:** Clear custodial framework documentation
- **Privacy Concerns:** Zero-knowledge proof integration planned

### Segregated Wallet Risks
- **User Key Loss:** Social recovery mechanism (3-of-5 guardians)
- **Security Policy Misconfiguration:** Automated policy validation
- **Upgrade Complexity:** Standardized upgrade patterns

### Migration Risks
- **Asset Transfer Failure:** Atomic transfer with rollback
- **State Inconsistency:** Dual-write verification
- **User Confusion:** Clear communication and support

---

**This visual guide complements the technical specification document.**  
**For detailed implementation, see: HYBRID_WALLET_IMPLEMENTATION.md**
