# Hybrid Wallet Architecture Implementation Plan
## Tokenize Banking Platform - Technical Specification

**Date:** March 30, 2026  
**Version:** 1.0  
**Status:** Ready for Development

---

## 🎯 Architecture Overview

### Hybrid Model Design
```
┌─────────────────────────────────────────────────────────────┐
│              Banking Platform Layer                         │
│  (Compliance, Reporting, Analytics)                         │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
┌───────▼────────────────────┐    ┌───────────▼────────────┐
│  Segregated Wallets        │    │  Omnibus Pool          │
│  (High-Value: >$50K)       │    │  (Retail: <$50K)       │
│  - Individual ERC-4337     │    │  - Shared Contract     │
│  - Custom Security         │    │  - Internal Ledger     │
│  - Non-Custodial           │    │  - Centralized Control │
└───────┬────────────────────┘    └───────────┬────────────┘
        │                                       │
        └───────────────┬───────────────────────┘
                        │
            ┌───────────▼────────────┐
            │  Hybrid Gateway        │
            │  (Auto-Migration)      │
            └────────────────────────┘
```

---

## 🏗️ Core Components

### 1. **HybridGateway Contract** (Central Orchestrator)
- User classification logic
- Auto-migration between tiers
- Compliance enforcement point
- Analytics aggregation

### 2. **SegregatedWalletFactory**
- Deploy individual ERC-4337 wallets
- Configure per-user security policies
- Manage upgrade paths

### 3. **OmnibusPoolContract**
- Multi-user custody contract
- Internal ledger management
- Batch transaction processing
- Centralized compliance checks

### 4. **MigrationManager**
- Seamless tier transitions
- Asset transfer automation
- State preservation during migration
- User notification system

---

## 📐 Technical Specifications

### Tier Classification Logic

```solidity
struct UserClassification {
    address userAddress;
    uint256 totalBalanceUSD;
    uint8 tierLevel; // 1=Retail, 2=High-Value, 3=Institutional
    bool isEligibleForMigration;
    uint256 lastReclassificationTime;
}

enum Tier {
    RETAIL,        // < $50K - Omnibus Pool
    HIGH_VALUE,    // $50K - $500K - Segregated Wallet
    INSTITUTIONAL  // > $500K - Enhanced Segregated + Custom Policies
}
```

### Migration Triggers

**Automatic Migration (Omnibus → Segregated):**
- Balance exceeds $50,000 USD equivalent
- User requests upgrade
- KYC level increases to Tier 2+

**Downgrade Path (Segregated → Omnibus):**
- Balance drops below $10,000 USD (30-day grace period)
- User explicitly requests downgrade
- Inactivity > 90 days

---

## 🔐 Smart Contract Architecture

### Contract 1: HybridGateway.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IHybridGateway.sol";

contract HybridGateway is AccessControl, IHybridGateway {
    // Roles
    bytes32 public constant MIGRATION_ADMIN = keccak256("MIGRATION_ADMIN");
    bytes32 public constant COMPLIANCE_OFFICER = keccak256("COMPLIANCE_OFFICER");

    // Configuration
    uint256 public constant RETAIL_THRESHOLD = 50_000 * 10**18; // $50K in smallest unit
    uint256 public constant HIGH_VALUE_THRESHOLD = 500_000 * 10**18; // $500K
    uint256 public constant DOWNGRADE_GRACE_PERIOD = 30 days;
    
    // State
    mapping(address => UserClassification) public userClassifications;
    address public omnibusPoolAddress;
    address public segregatedFactoryAddress;
    
    // Events
    event UserClassified(address indexed user, Tier tier, uint256 timestamp);
    event MigrationInitiated(address indexed user, Tier fromTier, Tier toTier);
    event MigrationCompleted(address indexed user, bool success);
    
    constructor() AccessControl() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MIGRATION_ADMIN, msg.sender);
        _grantRole(COMPLIANCE_OFFICER, msg.sender);
    }
    
    function classifyUser(address user) external returns (Tier) {
        UserClassification storage classification = userClassifications[user];
        
        uint256 balance = _getUserTotalBalance(user);
        classification.totalBalanceUSD = balance;
        
        Tier newTier;
        if (balance >= HIGH_VALUE_THRESHOLD) {
            newTier = Tier.INSTITUTIONAL;
        } else if (balance >= RETAIL_THRESHOLD) {
            newTier = Tier.HIGH_VALUE;
        } else {
            newTier = Tier.RETAIL;
        }
        
        // Check if tier changed
        if (classification.tierLevel != uint8(newTier)) {
            classification.tierLevel = uint8(newTier);
            classification.lastReclassificationTime = block.timestamp;
            
            emit UserClassified(user, newTier, block.timestamp);
            
            // Trigger migration if needed
            _triggerMigrationIfNeeded(user, newTier);
        }
        
        return newTier;
    }
    
    function _getUserTotalBalance(address user) internal view returns (uint256) {
        // Aggregate balances from all sources
        uint256 omnibusBalance = _getOmnibusBalance(user);
        uint256 segregatedBalance = _getSegregatedBalance(user);
        return omnibusBalance + segregatedBalance;
    }
    
    function _triggerMigrationIfNeeded(address user, Tier newTier) internal {
        UserClassification storage classification = userClassifications[user];
        
        if (newTier == Tier.HIGH_VALUE || newTier == Tier.INSTITUTIONAL) {
            // Need to migrate from omnibus to segregated
            if (classification.tierLevel == uint8(Tier.RETAIL)) {
                _initiateOmnibusToSegregatedMigration(user);
            }
        } else if (newTier == Tier.RETAIL) {
            // Check if downgrade is appropriate
            if (classification.tierLevel == uint8(Tier.HIGH_VALUE)) {
                if (block.timestamp - classification.lastReclassificationTime > DOWNGRADE_GRACE_PERIOD) {
                    _initiateSegregatedToOmnibusMigration(user);
                }
            }
        }
    }
    
    function initiateManualMigration(address user, Tier targetTier) external {
        require(hasRole(MIGRATION_ADMIN, msg.sender), "UNAUTHORIZED");
        // Implement manual migration logic
    }
    
    function setOmnibusPoolAddress(address _pool) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "UNAUTHORIZED");
        omnibusPoolAddress = _pool;
    }
    
    function setSegregatedFactoryAddress(address _factory) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "UNAUTHORIZED");
        segregatedFactoryAddress = _factory;
    }
}
```

### Contract 2: OmnibusPool.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IOmnibusPool.sol";

contract OmnibusPool is AccessControl, IOmnibusPool {
    bytes32 public constant WITHDRAWAL_APPROVER = keccak256("WITHDRAWAL_APPROVER");
    
    // Internal ledger
    struct UserLedger {
        uint256 balance;
        uint256 lastWithdrawalTime;
        bool isKycVerified;
        uint256 totalDeposited;
        uint256 totalWithdrawn;
    }
    
    mapping(address => UserLedger) public userLedgers;
    mapping(bytes32 => bool) public pendingWithdrawals;
    
    // Batch withdrawal queue
    struct WithdrawalBatch {
        address[] users;
        uint256[] amounts;
        uint256 timestamp;
        bool executed;
    }
    
    WithdrawalBatch[] public withdrawalBatches;
    
    function deposit(address token, uint256 amount) external override {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        UserLedger storage ledger = userLedgers[msg.sender];
        ledger.balance += amount;
        ledger.totalDeposited += amount;
        
        emit Deposit(msg.sender, token, amount, block.timestamp);
    }
    
    function requestWithdrawal(address token, uint256 amount) external override {
        UserLedger storage ledger = userLedgers[msg.sender];
        require(ledger.balance >= amount, "INSUFFICIENT_BALANCE");
        
        bytes32 withdrawalId = keccak256(abi.encodePacked(msg.sender, token, amount, block.timestamp));
        pendingWithdrawals[withdrawalId] = true;
        
        emit WithdrawalRequested(msg.sender, token, amount, withdrawalId);
    }
    
    function batchWithdraw(address[] calldata users, address[] calldata tokens, uint256[][] calldata amounts) external {
        require(hasRole(WITHDRAWAL_APPROVER, msg.sender), "UNAUTHORIZED");
        
        WithdrawalBatch memory batch;
        batch.timestamp = block.timestamp;
        
        for (uint256 i = 0; i < users.length; i++) {
            UserLedger storage ledger = userLedgers[users[i]];
            require(ledger.balance >= amounts[i][0], "INSUFFICIENT_BALANCE");
            
            ledger.balance -= amounts[i][0];
            ledger.totalWithdrawn += amounts[i][0];
        }
        
        withdrawalBatches.push(batch);
        
        emit BatchWithdrawalInitiated(users.length, batch.users.length);
    }
    
    function getOmnibusBalance(address user) external view returns (uint256) {
        return userLedgers[user].balance;
    }
}
```

### Contract 3: SegregatedWalletFactory.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./interfaces/ISegregatedWallet.sol";

contract SegregatedWalletFactory {
    address public constant ENTRYPOINT_ADDRESS = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    
    struct WalletConfig {
        uint256 dailyLimit;
        uint256 maxTransactionAmount;
        address[] authorizedOperators;
        uint256 requiredSignatures;
    }
    
    mapping(address => WalletConfig) public walletConfigs;
    mapping(bytes32 => address) public deployedWallets;
    
    event WalletDeployed(address indexed user, address indexed wallet, bytes32 salt);
    
    function deployWallet(
        address user,
        WalletConfig memory config,
        bytes32 salt
    ) external returns (address walletAddress) {
        require(walletConfigs[user].dailyLimit == 0, "WALLET_EXISTS");
        
        // Configure user's wallet settings
        walletConfigs[user] = config;
        
        // Deploy ERC-4337 compatible wallet using Create2
        bytes memory initCode = abi.encodePacked(
            type(SegregatedWallet).creationCode,
            abi.encode(user, ENTRYPOINT_ADDRESS)
        );
        
        walletAddress = Create2.computeAddress(salt, keccak256(initCode));
        
        if (walletAddress == address(0)) {
            // Deploy using standard method
            SegregatedWallet wallet = new SegregatedWallet(user, ENTRYPOINT_ADDRESS);
            walletAddress = address(wallet);
        } else {
            // Use Create2 deployment
            // Implementation depends on your wallet template
        }
        
        deployedWallets[salt] = walletAddress;
        
        emit WalletDeployed(user, walletAddress, salt);
    }
    
    function configureWallet(address user, WalletConfig memory config) external {
        require(walletConfigs[user].dailyLimit > 0, "NO_WALLET");
        walletConfigs[user] = config;
    }
}
```

### Contract 4: SegregatedWallet.sol (ERC-4337 Compatible)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "account-abstraction/contracts/entrypoint/IAccount.sol";
import "account-abstraction/contracts/samples/SimpleAccount.sol";

contract SegregatedWallet is AccessControl, IAccount {
    using ECDSA for bytes32;
    
    address public owner;
    address public entryPoint;
    
    // Security settings
    uint256 public dailyLimit;
    uint256 public maxTransactionAmount;
    uint256 public lastDailyReset;
    uint256 public dailySpent;
    
    constructor(address _owner, address _entryPoint) SimpleAccount(_owner, _entryPoint) {
        entryPoint = _entryPoint;
        owner = _owner;
        dailyLimit = 10 ether; // Default limit
        lastDailyReset = block.timestamp;
        dailySpent = 0;
    }
    
    function setDailyLimit(uint256 newLimit) external {
        require(msg.sender == owner, "NOT_OWNER");
        dailyLimit = newLimit;
        lastDailyReset = block.timestamp;
        dailySpent = 0;
    }
    
    function executeTransaction(address to, uint256 value, bytes calldata data) external returns (bool success) {
        require(block.timestamp >= lastDailyReset, "DAILY_LIMIT_RESET_REQUIRED");
        require(dailySpent + value <= dailyLimit, "EXCEEDS_DAILY_LIMIT");
        
        // Execute transaction
        (success, ) = to.call{value: value}(data);
        
        if (success) {
            dailySpent += value;
        }
        
        return success;
    }
    
    function validateUserOp(
        bytes calldata userOpHash,
        bytes calldata signature
    ) external view returns (uint256 validationData) {
        // Implement ERC-4337 validation logic
        // This is simplified - full implementation requires EntryPoint integration
        return 0; // 0 = valid
    }
}
```

---

## 🔄 Migration Flow Implementation

### Phase 1: Initiate Migration (Omnibus → Segregated)

```solidity
function initiateOmnibusToSegregatedMigration(address user) external {
    UserClassification storage classification = userClassifications[user];
    
    // Check eligibility
    require(classification.tierLevel == uint8(Tier.RETAIL), "NOT_ELIGIBLE");
    require(userClassifications[user].totalBalanceUSD >= RETAIL_THRESHOLD, "BELOW_THRESHOLD");
    
    // Get omnibus balance
    uint256 omnibusBalance = OmnibusPool(omnibusPoolAddress).getOmnibusBalance(user);
    
    // Create salt for deterministic deployment
    bytes32 salt = keccak256(abi.encodePacked(user, block.timestamp));
    
    // Deploy segregated wallet
    address newWallet = SegregatedWalletFactory(segregatedFactoryAddress).deployWallet(
        user,
        WalletConfig({
            dailyLimit: 10 ether,
            maxTransactionAmount: 1 ether,
            authorizedOperators: new address[](0),
            requiredSignatures: 1
        }),
        salt
    );
    
    // Transfer assets to new wallet
    OmnibusPool(omnibusPoolAddress).transferToWallet(user, newWallet, omnibusBalance);
    
    // Update classification
    classification.tierLevel = uint8(Tier.HIGH_VALUE);
    classification.isEligibleForMigration = false;
    
    emit MigrationInitiated(user, Tier.RETAIL, Tier.HIGH_VALUE);
}
```

### Phase 2: Downgrade Path (Segregated → Omnibus)

```solidity
function initiateSegregatedToOmnibusMigration(address user) external {
    UserClassification storage classification = userClassifications[user];
    
    // Check grace period
    require(block.timestamp - classification.lastReclassificationTime > DOWNGRADE_GRACE_PERIOD, "GRACE_PERIOD_ACTIVE");
    
    // Get segregated balance
    uint256 segregatedBalance = _getSegregatedBalance(user);
    
    // Transfer back to omnibus pool
    OmnibusPool(omnibusPoolAddress).depositFromWallet(user, segregatedBalance);
    
    // Close segregated wallet
    SegregatedWalletFactory(segregatedFactoryAddress).closeWallet(user);
    
    // Update classification
    classification.tierLevel = uint8(Tier.RETAIL);
    
    emit MigrationInitiated(user, Tier.HIGH_VALUE, Tier.RETAIL);
}
```

---

## 📊 Implementation Timeline

### Phase 1: Foundation (Weeks 1-4)
**Deliverables:**
- [ ] Deploy HybridGateway contract
- [ ] Implement user classification logic
- [ ] Set up compliance gateway integration
- [ ] Configure multi-sig governance

**Milestone:** Gateway operational, manual classification working

### Phase 2: Core Infrastructure (Weeks 5-8)
**Deliverables:**
- [ ] Deploy OmnibusPool contract
- [ ] Implement internal ledger system
- [ ] Create batch withdrawal processing
- [ ] Integrate with existing contracts

**Milestone:** Omnibus pool operational for retail users

### Phase 3: Segregated Wallets (Weeks 9-12)
**Deliverables:**
- [ ] Deploy SegregatedWalletFactory
- [ ] Implement ERC-4337 wallet templates
- [ ] Configure security policies
- [ ] Test deployment and configuration

**Milestone:** High-value users can deploy individual wallets

### Phase 4: Migration System (Weeks 13-16)
**Deliverables:**
- [ ] Implement auto-migration triggers
- [ ] Create MigrationManager contract
- [ ] Build user notification system
- [ ] Test seamless transitions

**Milestone:** Automatic tier migration operational

### Phase 5: Integration & Testing (Weeks 17-20)
**Deliverables:**
- [ ] Full system integration testing
- [ ] Security audit preparation
- [ ] User acceptance testing
- [ ] Production deployment

**Milestone:** Hybrid architecture production-ready

---

## 🔒 Security Considerations

### Omnibus Pool Security
1. **Multi-Sig Treasury Control**
   - 5-of-7 multisig for contract upgrades
   - 48-hour time lock on changes
   - Emergency pause mechanism

2. **Internal Controls**
   - Real-time balance monitoring
   - Anomaly detection algorithms
   - Automated withdrawal limits per user

3. **Insurance Fund**
   - 1% of total TVL in reserve
   - Third-party audit coverage
   - Cyber insurance policy

### Segregated Wallet Security
1. **Per-User Policies**
   - Customizable spending limits
   - Time-based restrictions (e.g., no transfers on weekends)
   - Whitelist-only transfers for high-value users

2. **Recovery Systems**
   - Social recovery (3-of-5 guardians)
   - Time-locked emergency access (7-day delay)
   - Identity verification for recovery

3. **Monitoring**
   - Individual transaction analysis
   - Behavioral biometrics integration
   - Real-time fraud detection alerts

---

## 📈 Performance Metrics

### Expected Performance
- **User Classification:** < 100ms per user
- **Migration Time:** < 5 minutes (automated)
- **Omnibus Batch Processing:** 1,000+ users per batch
- **Segregated Wallet Deployment:** < 30 seconds
- **Gas Savings:** ~40% vs pure segregated model

### Scalability Targets
- **Retail Users (Omnibus):** 100,000+ users
- **High-Value Users (Segregated):** 10,000+ wallets
- **Total Platform Capacity:** 150,000+ users

---

## 💰 Cost Analysis

### Development Costs
- **Phase 1-2 (Foundation + Omnibus):** $150K - $200K
- **Phase 3 (Segregated Wallets):** $100K - $150K
- **Phase 4-5 (Migration + Integration):** $75K - $100K
- **Total Development:** $325K - $450K

### Operational Costs (Annual)
- **Contract Maintenance:** $50K - $75K
- **Monitoring & Security:** $75K - $100K
- **Compliance Integration:** $50K - $75K
- **Total Annual OPEX:** $175K - $250K

### Gas Savings vs Pure Segregated
- **Retail Users (Omnibus):** 60-80% savings per transaction
- **High-Value Users (Segregated):** Standard costs
- **Overall Platform Savings:** ~40% reduction in gas costs

---

## 🎯 Next Steps

### Immediate Actions (This Week)
1. Review and approve smart contract designs
2. Set up development environment
3. Create testnet deployment scripts
4. Begin Phase 1 implementation

### Required Decisions
1. **Threshold Values:** Confirm $50K/$500K tier boundaries
2. **Security Policies:** Define default security settings for each tier
3. **Compliance Integration:** Select KYC/AML provider
4. **Governance Structure:** Define multisig composition

---

## 📚 Technical References

1. ERC-4337 Specification: https://eips.ethereum.org/EIPS/eip-4337
2. Account Abstraction Implementation Guide: https://docs.stackup.sh/
3. OpenZeppelin Contracts: https://docs.openzeppelin.com/contracts
4. ERC-6551 Token-Bound Accounts: https://eips.ethereum.org/EIPS/eip-6551

---

**Document Version:** 1.0  
**Last Updated:** March 30, 2026  
**Next Review:** After Phase 1 completion
