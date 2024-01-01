#!/bin/bash
#
# // Copyright (C) 2023 
#
# constant
FOLDER=".oraid"
CHAIN_ID=Oraichain
# VERSION=0.41.5
# NODENAME=nodename
# WALLET=wallet


# define screen colors:
RED='\e[0;31m'; CYAN='\e[1;36m'; GREEN='\e[0;32m'; BLUE='\e[1;34m'; PINK='\e[1m\e[35m'; NC='\e[0m';

echo -e "${CYAN}\nAutomatic Installer for Oraichain!${NC}";

# variable / input
default=$NODENAME
read -p "Please enter your NODENAME=[$default]: " NODENAME 
NODENAME=${NODENAME:-$default}

default=${VERSION}
read -p "Please enter docker pull VERSION=[$default]: " VERSION
VERSION=${VERSION:-$default}

default="Oraichain_13771328.tar.lz4"
echo -e "Check voor new snapshot version: ${GREEN}https://snapshots.nysa.network/Oraichain/#Oraichain/${NC}"
read -p "Enter new snapshot name [$default]: " SNAPSHOTS
SNAPSHOTS=${SNAPSHOTS:-$default}

echo -e "${CYAN}\nVerify the information below before proceeding with the installation!\n${NC}"
echo -e "NODENAME       : ${GREEN}$NODENAME${NC}"
echo -e "CHAIN ID       : ${GREEN}$CHAIN_ID${NC}"
echo -e "NODE VERSION   : ${GREEN}$VERSION${NC}"
echo -e "NODE FOLDER    : ${GREEN}~/$FOLDER${NC}"
echo -e "SNAPSHOTS      : ${GREEN}$SNAPSHOTS${NC}\n"

read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
    echo "export NODENAME=${NODENAME}" >> $HOME/.bash_profile
    echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.bash_profile
    echo "export FOLDER=${FOLDER}" >> $HOME/.bash_profile
    source $HOME/.bash_profile
else
    echo "Installation cancelled!"
    exit 1
fi


# Install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install build-essential make gcc net-tools curl git wget jq tmux ccze make lz4 ufw -y

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
    rm "go$ver.linux-amd64.tar.gz"
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi

# Download and build binaries
cd ~/ && rm -rf orai
git clone https://github.com/oraichain/orai.git && cd ~/orai
# checkout the latest tag
git checkout "v${VERSION}"
# in orai dir
cd ~/orai/orai
make install
cd ~/

# Config app
oraid init $NODENAME --chain-id $CHAIN_ID --home "$HOME/$FOLDER"
# oraid keys add $WALLET --recover

# Download configuration
curl -Ls https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/genesis.json > $HOME/.oraid/config/addrbook.json
curl -Ls https://snapshots.nysa.network/Oraichain/addrbook.json > $HOME/.oraid/config/addrbook.json

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

echo "# fix memory leak issue add this to the bottom of app.toml">> $HOME/.oraid/config/app.toml
echo "[wasm]" >> $HOME/.oraid/config/app.toml
echo "query_gas_limit = 300000" >> $HOME/.oraid/config/app.toml
echo "memory_cache_size = 400" >> $HOME/.oraid/config/app.toml


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
curl -L https://snapshots.nysa.network/Oraichain/${SNAPSHOTS} | tar -Ilz4 -xf - -C ~/.oraid

# Register and start service
sudo systemctl daemon-reload
sudo systemctl enable oraid
sudo systemctl restart oraid && sudo journalctl -u oraid -f -o cat
