#!/bin/bash
# Create a clean repository for admin dashboard only

echo "🧹 Creating clean repository..."

cd /home/bram/.nanobot/workspace/tokenize

# Remove all unnecessary files
rm -rf contracts scripts test deployments artifacts cache node_modules utils
rm -f .env .env.example hardhat.config.js package.json package-lock.json
rm -f cleanup-repo.sh deploy-instructions.sh deploy-to-github-pages.sh reset-repo.sh
rm -f STATE.md TODO.md

# Keep only essential files
ls -la

echo ""
echo "✅ Repository cleaned!"
