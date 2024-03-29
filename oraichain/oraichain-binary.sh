#!/bin/bash
#
# // Copyright (C) 2023 
# // Build the binary from source
# constant
# CHAIN_ID=Oraichain
# FOLDER=".oraid"
# MONIKER=nodename
# WALLET=wallet
# VERSION=0.41.5

# define screen colors:
red='\e[0;31m'; cyan='\e[1;36m'; green='\e[0;32m'; blue='\e[1;34m'; pink='\e[1m\e[35m'; nc='\e[0m';

echo -e "${cyan}\nAutomatic Installer for Oraichain!${nc}";

# variable / input
default=$CHAIN_ID
read -p "Please enter CHAIN_ID=[$default]: " CHAIN_ID 
CHAIN_ID=${CHAIN_ID:-$default}

default=$MONIKER
read -p "Please enter your MONIKER=[$default]: " MONIKER 
MONIKER=${MONIKER:-$default}

default=${VERSION}
read -p "Please enter docker pull VERSION=[$default]: " VERSION
VERSION=${VERSION:-$default}

default="Oraichain_15106803.tar.lz4"
echo -e "Check voor new snapshot version: ${green}https://snapshots.nysa.network/Oraichain/#Oraichain/${nc}"
read -p "Enter new snapshot name [$default]: " SNAPSHOTS
SNAPSHOTS=${SNAPSHOTS:-$default}

echo -e "${cyan}\nVerify the information below before proceeding with the installation!\n${nc}"
echo -e "MONIKER        : ${green}$MONIKER${nc}"
echo -e "WALLET         : ${green}$WALLET${nc}"
echo -e "CHAIN ID       : ${green}$CHAIN_ID${nc}"
echo -e "NODE VERSION   : ${green}$VERSION${nc}"
echo -e "NODE FOLDER    : ${green}$HOME/$FOLDER${nc}"
echo -e "SNAPSHOTS      : ${green}$SNAPSHOTS${nc}\n"

read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
    echo "export CHAIN_ID=${CHAIN_ID}" >> ~/.bash_profile
    echo "export FOLDER=${FOLDER}" >> ~/.bash_profile
    echo "export MONIKER=${MONIKER}" >> ~/.bash_profile
    echo "export WALLET=${WALLET}" >> ~/.bash_profile
    echo "export VERSION=${VERSION}" >> ~/.bash_profile
    source $HOME/.bash_profile  
else
    echo "Installation cancelled!"
    exit 1
fi


# Install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install build-essential make gcc net-tools curl git wget jq lz4 ufw -y

# firewall setup
# sudo ufw allow 443/udp
# sudo ufw allow 22,26656:26657/tcp
# sudo ufw --force enable 
# sudo ufw status verbose
# sudo ufw status numbered

# Install go
if ! [ -x "$(command -v go)" ]; then
    ver="1.19.4"
    cd $HOME
    sudo rm -rf /usr/local/go
    wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
    sudo rm "go$ver.linux-amd64.tar.gz"
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
    sleep 2.5 && source $HOME/.bash_profile
fi

# Download and build binaries
cd ~/ && rm -rf orai
git clone https://github.com/oraichain/orai.git && cd ~/orai
#git fetch --tags
# checkout the latest tag
git checkout "v${VERSION}"
# in orai dir
cd ~/orai/orai
make install
cd ~/

# Config app
oraid init $MONIKER --chain-id $CHAIN_ID --home "$HOME/$FOLDER"
# oraid keys add $WALLET --recover

# Download configuration
wget -O $HOME/.oraid/config/genesis.json https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/genesis.json
wget -O $HOME/.oraid/config/addrbook.json https://snapshots.nysa.network/Oraichain/addrbook.json

# Set seeds and peers
sed -E -i 's/seeds = \".*\"/seeds = \"4d0f2d042405abbcac5193206642e1456fe89963@3.134.19.98:26656,24631e98a167492fd4c92c582cee5fd6fcd8ad59@162.55.253.58:26656,bf083c57ed53a53ccd31dc160d69063c73b340e9@3.17.175.62:26656,35c1f999d67de56736b412a1325370a8e2fdb34a@5.189.169.99:26656,5ad3b29bf56b9ba95c67f282aa281b6f0903e921@64.225.53.108:26656,d091cabe3584cb32043cc0c9199b0c7a5b68ddcb@seed.orai.synergynodes.com:26656\"/' $HOME/.oraid/config/config.toml

# Disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.oraid/config/config.toml

# Config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.oraid/config/app.toml

# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025orai\"|" $HOME/.oraid/config/app.toml

# Fix memory leak
echo "# Fix memory leak issue add this to the bottom of app.toml">> $HOME/.oraid/config/app.toml
echo "[wasm]" >> $HOME/.oraid/config/app.toml
echo "query_gas_limit = 300000" >> $HOME/.oraid/config/app.toml
echo "# [400|2000] MiB" >> $HOME/.oraid/config/app.toml
echo "memory_cache_size = 2000" >> $HOME/.oraid/config/app.toml


# State sync
state_sync_rpc=https://rpc.orai.io:443
latest_height=$(curl -s $state_sync_rpc/block | jq -r .result.block.header.height)
sync_block_height=$(($latest_height - 2002))
sync_block_hash=$(curl -s "$state_sync_rpc/block?height=$sync_block_height" | jq -r .result.block_id.hash)
echo $latest_height $sync_block_height $sync_block_hash

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
  s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$state_sync_rpc,$state_sync_rpc\"| ; \
  s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$sync_block_height| ; \
  s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$sync_block_hash\"|" $HOME/.oraid/config/config.toml

# Create service
sudo tee /etc/systemd/system/oraid.service > /dev/null <<EOF
[Unit]
Description=Orai Network Node
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=$(which oraid) start --home /root/.oraid
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Download snapshot
# curl -L https://snapshots.nysa.network/Oraichain/${SNAPSHOTS} | tar -Ilz4 -xf - -C ~/.oraid

# Register and start service
sudo systemctl daemon-reload
sudo systemctl enable oraid
sudo systemctl restart oraid && sudo journalctl -u oraid -f -o cat

# Use this command to switch off your State Sync mode, after node fully synced to avoid problems in future node restarts!
# Disable State sync
# $ sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.oraid/config/config.toml
# $ sed -i.bak -E "s|^(filter_peers[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.oraid/config/config.toml
#
