import pkg from 'hardhat';
const { ethers } = pkg;
import fs from "fs";

async function main() {
  console.log("🏦 Deploying RegulatedYieldVault...\n");
  
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  
  const provider = ethers.provider;
  const balance = await provider.getBalance(deployer.address);
  console.log("Balance:", ethers.formatEther(balance), "ETH");
  
  if (balance === 0n) {
    console.log("❌ No ETH!");
    return;
  }

  // Deploy RegulatedYieldVault
  console.log("\n1. Deploying RegulatedYieldVault...");
  const RegulatedYieldVault = await ethers.getContractFactory("RegulatedYieldVault");
  const vault = await RegulatedYieldVault.deploy();
  await vault.waitForDeployment();
  const vaultAddress = await vault.getAddress();
  console.log("   ✅ RegulatedYieldVault deployed to:", vaultAddress);

  // Link to NAV Tracker
  console.log("\n2. Linking to NAV Tracker...");
  const TRACKER_ADDRESS = "0x38Bd612fd94Fac2faA1240478Ac56b55b20A48B8";
  
  const tracker = await ethers.getContractAt("FundNAVTracker", TRACKER_ADDRESS);
  
  // Check if we have admin role
  const hasAdminRole = await tracker.hasRole(await tracker.DEFAULT_ADMIN_ROLE(), deployer.address);
  console.log("   Admin Role:", hasAdminRole ? "✅ Yes" : "❌ No");

  if (!hasAdminRole) {
    console.log("\n⚠️  Warning: You don't have admin role on the tracker!");
    console.log("You need to be the deployer or have admin role granted.");
    return;
  }

  // Link the vault to the tracker
  const TARGET_NAV = ethers.parseUnits("100", 18); // $100 per share
  const TOLERANCE_BPS = 50; // 0.5%
  
  console.log(`   Target NAV: $${ethers.formatUnits(TARGET_NAV, 18)}`);
  console.log(`   Tolerance: ${TOLERANCE_BPS} basis points (${TOLERANCE_BPS/100}%)`);

  const tx = await tracker.linkExternalFund(vaultAddress, TARGET_NAV, TOLERANCE_BPS);
  console.log("   Transaction sent:", tx.hash);
  
  console.log("\n⏳ Waiting for confirmation...");
  const receipt = await tx.wait();
  
  console.log("\n✅ Vault linked successfully!");
  console.log("   Block:", receipt.blockNumber);
  console.log("   Gas Used:", receipt.gasUsed.toString());

  // Update vault with tracker address
  console.log("\n3. Updating vault with tracker address...");
  const updateTx = await vault.setNAVTracker(TRACKER_ADDRESS);
  await updateTx.wait();
  console.log("   ✅ Vault updated with NAV Tracker");

  // Save deployment info
  const deploymentInfo = {
    network: "sepolia",
    contracts: {
      regulatedYieldVault: vaultAddress,
      fundNavTracker: TRACKER_ADDRESS,
      simplePriceOracle: "0xc6510836743f311Ac78d370Aa34e6Ee871609c40"
    },
    configuration: {
      targetNAV: TARGET_NAV.toString(),
      toleranceBps: TOLERANCE_BPS,
      timestamp: new Date().toISOString()
    }
  };
  
  fs.writeFileSync("deployments/regulated-yield-vault.json", JSON.stringify(deploymentInfo, null, 2));
  
  console.log("\n📄 Deployment info saved to deployments/regulated-yield-vault.json");
  console.log("🔗 RegulatedYieldVault: https://sepolia.etherscan.io/address/" + vaultAddress);
  console.log("🔗 NAV Tracker: https://sepolia.etherscan.io/address/" + TRACKER_ADDRESS);
  
  console.log("\n✅ Complete NAV Tracking System Deployed!");
  console.log("\nNext Steps:");
  console.log("1. Deposit tokens to the vault to start generating yield");
  console.log("2. Monitor NAV via dashboard");
  console.log("3. Watch for automatic rebalancing when deviation > 0.5%");
}

main().catch(console.error);
