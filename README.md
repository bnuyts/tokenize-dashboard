# Tokenize Admin Dashboard - Clean Repository

🚀 **Live Dashboards:**
- **Admin Dashboard:** https://bnuyts.github.io/tokenize-dashboard/admin-dashboard.html
- **NAV Monitor:** https://bnuyts.github.io/tokenize-dashboard/nav-monitor-dashboard.html

---

## 📋 Overview

This repository contains the admin and monitoring dashboards for the Tokenize blockchain banking platform. The dashboards provide web-based interfaces to monitor and manage all deployed smart contracts, including our new NAV tracking system.

---

## 🔐 Security

- ✅ Repository is **private** - only you can see the code on GitHub
- ✅ Dashboards are **publicly accessible** via URL (as designed for GitHub Pages)
- ✅ No sensitive data stored in the repository
- ✅ MetaMask required for wallet connection and contract management
- ✅ All `.md` documentation files are hidden from public view

---

## 🎯 Features

### Real-Time Monitoring
- Live status indicators for all contracts
- Contract addresses with one-click copy
- Activity log with timestamps
- **NEW:** NAV tracking with real-time deviation monitoring

### Contract Management
- **ERC-20 CrossBorderPayment**: Set daily transfer limits
- **ERC-3643 SecurityToken**: Manage investor identities and accreditation
- **ERC-5564 IdentityRegistry**: Verify identities with ZK proofs
- **ERC-4337 InstitutionWallet**: Sponsor addresses for gasless transactions
- **SimplePriceOracle**: Price feed management
- **TestOracle**: Test contract for deployment verification

### NAV Tracking System (NEW!)
- Real-time NAV calculation and monitoring
- External fund benchmarking
- Automatic rebalancing when deviation exceeds tolerance
- Historical NAV tracking with charts
- Deviation alerts and controls

### User Interface
- Responsive design (mobile-friendly)
- Professional UI with Tailwind CSS
- Real-time activity logging
- Etherscan integration
- Interactive charts and graphs

---

## 📁 Repository Contents

| File | Description |
|------|-------------|
| `admin-dashboard.html` | Main admin dashboard interface |
| `nav-monitor-dashboard.html` | NAV tracking monitoring dashboard |
| `index.html` | Landing page redirect |
| `README.md` | This documentation file |

**Note:** All `.md` documentation files are hidden from public view but remain in your local filesystem.

---

## 🚀 Quick Start

### Admin Dashboard
1. **Open the dashboard:** https://bnuyts.github.io/tokenize-dashboard/admin-dashboard.html
2. **Connect MetaMask:** Click "Connect Wallet" button
3. **Manage contracts:** Use the management interface to control your contracts
4. **Monitor activity:** View real-time activity log

### NAV Monitor Dashboard
1. **Open the monitor:** https://bnuyts.github.io/tokenize-dashboard/nav-monitor-dashboard.html
2. **View real-time NAV:** See current NAV and target values
3. **Track deviations:** Monitor deviation from target NAV
4. **Control rebalancing:** Pause/resume tracking and adjust parameters

---

## 🔧 Maintenance

### Updating the Dashboards

1. Edit HTML files locally (`admin-dashboard.html` or `nav-monitor-dashboard.html`)
2. Commit changes:
   ```bash
   git commit -am "Update dashboard"
   ```
3. Push to GitHub:
   ```bash
   git push origin main
   ```
4. Changes will be live within 1-2 minutes

### Updating Contract Addresses

If you redeploy contracts, update the addresses in the respective dashboard files:

**Admin Dashboard:**
```javascript
const CONTRACT_ADDRESSES = {
    erc20: 'YOUR_NEW_ERC20_ADDRESS',
    erc3643: 'YOUR_NEW_ERC3643_ADDRESS',
    erc5564: 'YOUR_NEW_ERC5564_ADDRESS',
    erc4337: 'YOUR_NEW_ERC4337_ADDRESS'
};
```

**NAV Monitor:**
```javascript
const CONTRACT_ADDRESSES = {
    oracle: 'YOUR_ORACLE_ADDRESS',
    tracker: 'YOUR_NAV_TRACKER_ADDRESS'
};
```

---

## 📊 Deployed Contracts (Sepolia Testnet)

### Core Banking Contracts
| Standard | Contract | Address | Status |
|----------|----------|---------|--------|
| ERC-20 | CrossBorderPayment | `0x59f40d0e...` | ✅ LIVE |
| ERC-3643 | SecurityToken | `0xb0D7D3b4...` | ✅ LIVE |
| ERC-5564 | IdentityRegistry | `0xCA9Be17D...` | ✅ LIVE |
| ERC-4337 | InstitutionWallet | `0x6CAC545a...` | ✅ LIVE |

### NAV Tracking System (NEW!)
| Contract | Address | Status |
|----------|---------|--------|
| TestOracle | `0x22Fe8C95...` | ✅ LIVE |
| SimplePriceOracle | `0x800E9A04...` | ✅ LIVE |

**View on Etherscan:** https://sepolia.etherscan.io/

---

## 🌐 Access

- **Admin Dashboard:** https://bnuyts.github.io/tokenize-dashboard/admin-dashboard.html
- **NAV Monitor:** https://bnuyts.github.io/tokenize-dashboard/nav-monitor-dashboard.html
- **GitHub Repo:** https://github.com/bnuyts/tokenize-dashboard (private)
- **Etherscan Sepolia:** https://sepolia.etherscan.io/

---

## 📈 NAV Tracking Features

### Real-Time Monitoring
- Current NAV per share
- Target NAV configuration
- Deviation from target (in basis points)
- Historical NAV tracking with charts

### Automatic Rebalancing
- Configurable tolerance thresholds
- Automatic trigger when deviation exceeds limits
- Rebalance history and counts
- Pause/resume controls

### External Fund Benchmarking
- Link external funds for comparison
- Custom target NAV per fund
- Tolerance configuration per fund
- Multi-fund support (future)

---

## 🎁 What's New

### April 2026 - NAV Tracking System
- ✅ Deployed SimplePriceOracle and TestOracle
- ✅ Created comprehensive NAV tracking contract
- ✅ Built interactive monitoring dashboard with charts
- ✅ Implemented automatic rebalancing logic
- ✅ Added deviation alerts and controls

### Previous Versions
- ✅ All four core banking contracts deployed and verified
- ✅ Admin dashboard with full contract management
- ✅ Activity logging and Etherscan integration
- ✅ Mobile-responsive design

---

**Built with ❤️ for Tokenize Platform**
