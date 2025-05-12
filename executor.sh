#!/bin/bash

# Update and install necessary packages
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y || { echo "Failed to update system"; exit 1; }
sudo apt install -y build-essential git screen wget || { echo "Failed to install packages"; exit 1; }

# Download and extract the latest executor binary
echo "Downloading and extracting T3rn executor..."
wget -q --show-progress https://github.com/t3rn/executor-release/releases/download/v0.77.1/executor-linux-v0.77.1tar.gz || { echo "Download failed"; exit 1; }
tar -xvzf executor-linux-v0.77.1tar.gz || { echo "Extraction failed"; exit 1; }
cd executor/executor/bin || { echo "Directory change failed"; exit 1; }

# Export environment variables
echo "Setting environment variables..."
export ENVIRONMENT=testnet
export APP_NAME=local
export INSTANCE=alfa
export PRIVATE_KEY_LOCAL=
export EXECUTOR_ENABLED_ASSETS=eth,t3eth,t3mon,mon,sei,t3sei,t3usd,t3btc
export NETWORKS_DISABLED=base,optimism,arbitrum,blast-sepolia
export EXECUTOR_ENABLED_NETWORKS="arbitrum-sepolia,base-sepolia,optimism-sepolia,unichain-sepolia,l2rn,sei-testnet,monad-testnet"
export EXECUTOR_MAX_L3_GAS_PRICE=2000
export LOG_LEVEL=info
export LOG_PRETTY=false
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
export EXECUTOR_PROCESS_BIDS_API_ENABLED=false
export EXECUTOR_MIN_BALANCE_THRESHOLD_ETH=0
export EXECUTOR_ENABLE_BIDDING_PROCESSING=false


# Add RPC endpoints
echo "Configuring RPC endpoints..."
export RPC_ENDPOINTS='{
    "l2rn": ["https://t3rn-b2n.blockpi.network/v1/rpc/public", "https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "blst": ["https://sepolia.blast.io", "https://blast-sepolia.drpc.org"],
    "mont": ["https://testnet-rpc.monad.xyz"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"]
}'

# Display ASCII art and info
echo "Starting T3rn executor setup..."
cat << 'EOF'

██ ███    ██ ██    ██ ██  ██████ ████████ ██    ██ ███████     ██       █████  ██████  ███████ 
██ ████   ██ ██    ██ ██ ██         ██    ██    ██ ██          ██      ██   ██ ██   ██ ██      
██ ██ ██  ██ ██    ██ ██ ██         ██    ██    ██ ███████     ██      ███████ ██████  ███████ 
██ ██  ██ ██  ██  ██  ██ ██         ██    ██    ██      ██     ██      ██   ██ ██   ██      ██ 
██ ██   ████   ████   ██  ██████    ██     ██████  ███████     ███████ ██   ██ ██████  ███████ 

=== T3rn Testnet V2 ===
EOF
sleep 1

# Ask user for private key securely
read -s -p "Enter your T3rn Wallet Private Key: " PRIVATE_KEY_LOCAL
echo
export PRIVATE_KEY_LOCAL

# Start executor in a Screen session
echo "Starting T3rn executor in Screen session..."
screen -dmS t3rn bash -c "./executor; exec bash"

# Wait briefly and check if it’s running
sleep 5
if screen -list | grep -q "t3rn"; then
    echo "Executor started successfully in Screen session 't3rn'. Use 'screen -r t3rn' to attach."
else
    echo "Executor failed to start. Check logs or retry."
    exit 1
fi
