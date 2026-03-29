# Tokenize Admin Dashboard - Clean Repository

🚀 **Live Dashboard:** https://bnuyts.github.io/tokenize-dashboard/admin-dashboard.html

---

## 📋 Overview

This repository contains the admin dashboard for the Tokenize blockchain banking platform. The dashboard provides a web-based interface to monitor and manage all four deployed smart contracts.

---

## 🔐 Security

- ✅ Repository is **private** - only you can see the code on GitHub
- ✅ Dashboard is **publicly accessible** via URL (as designed for GitHub Pages)
- ✅ No sensitive data stored in the repository
- ✅ MetaMask required for wallet connection and contract management

---

## 🎯 Features

### Real-Time Monitoring
- Live status indicators for all 4 contracts
- Contract addresses with one-click copy
- Activity log with timestamps

### Contract Management
- **ERC-20 CrossBorderPayment**: Set daily transfer limits
- **ERC-3643 SecurityToken**: Manage investor identities and accreditation
- **ERC-5564 IdentityRegistry**: Verify identities with ZK proofs
- **ERC-4337 InstitutionWallet**: Sponsor addresses for gasless transactions

### User Interface
- Responsive design (mobile-friendly)
- Professional UI with Tailwind CSS
- Real-time activity logging
- Etherscan integration

---

## 📁 Repository Contents

| File | Description |
|------|-------------|
| `admin-dashboard.html` | Main admin dashboard interface |
| `README.md` | This documentation file |

---

## 🚀 Quick Start

1. **Open the dashboard:** https://bnuyts.github.io/tokenize-dashboard/admin-dashboard.html
2. **Connect MetaMask:** Click "Connect Wallet" button
3. **Manage contracts:** Use the management interface to control your contracts
4. **Monitor activity:** View real-time activity log

---

## 🔧 Maintenance

### Updating the Dashboard

1. Edit `admin-dashboard.html` locally
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

If you redeploy contracts, update the addresses in `admin-dashboard.html`:

```javascript
const CONTRACT_ADDRESSES = {
    erc20: 'YOUR_NEW_ERC20_ADDRESS',
    erc3643: 'YOUR_NEW_ERC3643_ADDRESS',
    erc5564: 'YOUR_NEW_ERC5564_ADDRESS',
    erc4337: 'YOUR_NEW_ERC4337_ADDRESS'
};
```

---

## 📊 Deployed Contracts

| Standard | Contract | Address | Status |
|----------|----------|---------|--------|
| ERC-20 | CrossBorderPayment | `0x59f40d0e...` | ✅ LIVE |
| ERC-3643 | SecurityToken | `0xb0D7D3b4...` | ✅ LIVE |
| ERC-5564 | IdentityRegistry | `0xCA9Be17D...` | ✅ LIVE |
| ERC-4337 | InstitutionWallet | `0x6CAC545a...` | ✅ LIVE |

---

## 🌐 Access

- **Dashboard URL:** https://bnuyts.github.io/tokenize-dashboard/admin-dashboard.html
- **GitHub Repo:** https://github.com/bnuyts/tokenize-dashboard (private)
- **Etherscan Sepolia:** https://sepolia.etherscan.io/

---

**Built with ❤️ for Tokenize Platform**
