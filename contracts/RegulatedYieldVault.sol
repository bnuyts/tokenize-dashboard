// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title RegulatedYieldVault
 * @dev Simple yield vault for testing NAV tracking system
 */
contract RegulatedYieldVault is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    address public navTracker;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    uint256 public lastYieldDistribution;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event YieldDistributed(uint256 amount, uint256 timestamp);
    event NAVTrackerUpdated(address indexed tracker);

    constructor() ERC20("RegulatedYieldVault", "RYV") AccessControl() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setNAVTracker(address _tracker) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "UNAUTHORIZED");
        navTracker = _tracker;
        emit NAVTrackerUpdated(_tracker);
    }

    function deposit(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "ZERO_AMOUNT");
        
        shares = _deposit(msg.sender, amount);
        totalDeposits += amount;
        
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "ZERO_SHARES");
        
        amount = _withdraw(msg.sender, shares);
        totalWithdrawals += amount;
        
        emit Withdraw(msg.sender, amount);
    }

    function _deposit(address to, uint256 amount) internal returns (uint256 shares) {
        // Simple NAV calculation: $100 per share initially
        uint256 nav = 100 * 1e18; // Mock NAV
        
        if (nav == 0) {
            shares = amount;
        } else {
            shares = (amount * 1e18) / nav;
        }
        
        _mint(to, shares);
        return shares;
    }

    function _withdraw(address from, uint256 shares) internal returns (uint256 amount) {
        uint256 nav = 100 * 1e18; // Mock NAV
        
        if (nav == 0) {
            amount = shares;
        } else {
            amount = (shares * nav) / 1e18;
        }
        
        _burn(from, shares);
        return amount;
    }

    function getNAV() external view returns (uint256) {
        uint256 totalAssets = balanceOf(address(this));
        uint256 totalShares = totalSupply();
        
        if (totalShares == 0) {
            return 100 * 1e18; // Default $100
        }
        
        return (totalAssets * 1e18) / totalShares;
    }

    function distributeYield() external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "UNAUTHORIZED");
        
        uint256 totalAssets = balanceOf(address(this));
        uint256 totalShares = totalSupply();
        
        if (totalShares == 0) return;
        
        // Calculate yield to distribute (simplified)
        uint256 yieldAmount = totalAssets / 100; // 1% of assets
        
        if (yieldAmount > 0) {
            _burn(address(this), yieldAmount);
            emit YieldDistributed(yieldAmount, block.timestamp);
        }
    }

    function updateNAVTracker() external view returns (uint256 nav) {
        if (navTracker != address(0)) {
            // In production, this would call the tracker
            return 100 * 1e18; // Return mock value
        }
        return 0;
    }
}
