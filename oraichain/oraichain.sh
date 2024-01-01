#!/bin/bash
#
# // Copyright (C) 2023 
#
# constant
CHAIN_ID=Oraichain
FOLDER=.oraid
REPO=https://github.com/oraichain/orai

# Define screen colors:
RED='\e[0;31m'; CYAN='\e[1;36m'; GREEN='\e[0;32m'; BLUE='\e[1;34m'; PINK='\e[1m\e[35m'; NC='\e[0m';

echo -e "${CYAN} \t\t Automatic Installer for Oraichain | Chain ID : $CHAIN_ID ${NC}";

# variable / input
default=$NODENAME
read -p "Please enter your NODENAME [$default]: " NODENAME
NODENAME=${NODENAME:-$default}

default=${VERSION}
read -p "Please enter docker pull version [$default]: " VERSION
VERSION=${VERSION:-$default}

default="Oraichain_15106803.tar.lz4"
echo -e "Check voor new snapshot version: ${GREEN}https://snapshots.nysa.network/Oraichain/#Oraichain/${NC}"
read -p "Enter new snapshot name [$default]: " SNAPSHOTS
SNAPSHOTS=${SNAPSHOTS:-$default}

echo -e "\nVerify the information below before proceeding with the installation!\n"
echo -e "NODENAME       : ${GREEN}$NODENAME${NC}"
echo -e "CHAIN ID       : ${GREEN}$CHAIN_ID${NC}"
echo -e "NODE VERSION   : ${GREEN}$VERSION${NC}"
echo -e "NODE FOLDER    : ${GREEN}$FOLDER${NC}"
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

#🏀 install recommended apps
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common lz4 jq -y

#🏀 Edit orai.env & docker-compose.yml
curl -OL https://raw.githubusercontent.com/celik23/bash/main/oraichain/docker-compose.yml && curl -OL https://raw.githubusercontent.com/celik23/bash/main/oraichain/orai.env

# find and replace
sed -i -e "s/^USER *=.*/USER=$NODENAME/" $HOME/orai.env
sed -i -e "s/^MONIKER *=.*/MONIKER=$NODENAME/" $HOME/orai.env
sed -i -e "s/0.41.4/$VERSION/" $HOME/docker-compose.yml

# Build and enter the container
docker-compose pull && docker-compose up -d --force-recreate

# Download Chain Data
mkdir -p $HOME/.oraid/config
curl -L https://snapshots.nysa.network/Oraichain/$SNAPSHOTS | tar -Ilz4 -xf - -C $HOME/.oraid

# remove 
rm $HOME/.oraid/config/genesis.json

# Config app
docker exec -it orai_node /bin/bash -c "oraid init $NODENAME --chain-id "${CHAIN_ID}""

#⛔ oraid keys add $NODENAME 2>&1 | tee account.txt && exit
#       👆 OR 👇
#👉 import exist wallet (recover wallet)
# ???docker exec -it orai_node /bin/bash -c 'oraid keys add $NODENAME --recover'

# Download genesis.json
wget -O $HOME/.oraid/config/genesis.json https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/genesis.json


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


# docker-compose restart orai && docker-compose exec -d orai bash -c 'oraivisor start'
docker-compose restart orai && docker-compose exec orai bash -c 'oraivisor start --p2p.pex false --p2p.persistent_peers "e6fa2f222236a9ca5e10b238de87eb12497a649c@167.99.119.182:26656,911b290c59a4d3248534b53bdbc8dd4615bb5870@167.99.119.182:26656,35c1f999d67de56736b412a1325370a8e2fdb34a@5.189.169.99:26656,5ad3b29bf56b9ba95c67f282aa281b6f0903e921@64.225.53.108:26656"'

#
