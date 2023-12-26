#!/bin/bash
#
# // Copyright (C) 2023 
#

# constant
CHAIN_ID=Oraichain
FOLDER=.oraid
REPO=https://github.com/oraichain/orai
PORT=266

# Define screen colors:
RED='\e[0;31m'; CYAN='\e[1;36m'; GREEN='\e[0;32m'; BLUE='\e[1;34m'; PINK='\e[1m\e[35m'; NC='\e[0m';

echo -e "${CYAN} \t\t\t Automatic Installer for Oraichain | Chain ID : $CHAIN_ID ${NC}";

# variable / input
default=$MONIKER
read -p "Please enter your MONIKER NAME [$default]: " MONIKER
MONIKER=${MONIKER:-$default}

default=${VERSION}
read -p "Please enter docker pull version [$default]: " VERSION
VERSION=${VERSION:-$default}

default="Oraichain_13771328.tar.lz4"
echo -e "${GREEN}Check voor new snapshot version:${CYAN} https://snapshots.nysa.network/Oraichain/#Oraichain/${NC}"
read -p "Enter new snapshot name [$default]: " SNAPSHOTS
SNAPSHOTS=${SNAPSHOTS:-$default}

echo "Verify the information below before proceeding with the installation!\n"
echo -e "MONIKER        : ${GREEN}$MONIKER${NC}"
echo -e "CHAIN ID       : ${GREEN}$CHAIN_ID${NC}"
echo -e "NODE VERSION   : ${GREEN}$VERSION${NC}"
echo -e "NODE FOLDER    : ${GREEN}$FOLDER${NC}"
echo -e "SNAPSHOTS      : ${GREEN}$SNAPSHOTS${NC}\n"

read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
    echo "export MONIKER=${MONIKER}" >> $HOME/.bash_profile
    echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.bash_profile
    echo "export FOLDER=${FOLDER}" >> $HOME/.bash_profile
    source $HOME/.bash_profile
else
    echo "Installation cancelled!"
    exit 1
fi

#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🏀 install recommended apps
sudo apt update -y
sudo apt install -y git ufw curl lz4 jq

#🏀 Edit orai.env & docker-compose.yml
curl -OL https://raw.githubusercontent.com/celik23/bash/main/oraichain/docker-compose.yml && curl -OL https://raw.githubusercontent.com/celik23/bash/main/oraichain/orai.env

# find and replace
sed -i -e "s/^USER *=.*/USER=$MONIKER/" $HOME/orai.env
sed -i -e "s/^MONIKER *=.*/MONIKER=$MONIKER/" $HOME/orai.env
sed -i -e "s/0.41.3/$VERSION/" $HOME/docker-compose.yml

# Build and enter the container
docker-compose pull && docker-compose up -d --force-recreate

# Download Chain Data
mkdir -p $HOME/.oraid/config
curl -L https://snapshots.nysa.network/Oraichain/$SNAPSHOTS | tar -Ilz4 -xf - -C $HOME/.oraid
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
rm $HOME/.oraid/config/genesis.json
docker exec -it orai_node /bin/bash -c 'oraid init $MONIKER --chain-id "$CHAIN_ID"'
#⛔ oraid keys add $MONIKER 2>&1 | tee account.txt && exit
#       👆 OR 👇
#👉 import exist wallet (recover wallet)
docker exec -it orai_node /bin/bash -c 'oraid keys add $MONIKER --recover'
# Enter keyring passphrase:
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# Download genesis.json
wget -O $HOME/.oraid/config/genesis.json https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/genesis.json

# Netwrok setup | Replace config.toml and app.toml
wget -O $HOME/oraichain-network.sh https://raw.githubusercontent.com/celik23/bash/main/oraichain/oraichain-network.sh && chmod +x oraichain-network.sh && $HOME/oraichain-network.sh
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🛑 screen -ls <list-session> | screen -S <new-session-name> | screen -r <session-name> | screen -d -r 27863 <detaching>
# screen -S home
# docker-compose restart orai && docker-compose exec -d orai bash -c 'oraivisor start'
docker-compose restart orai && docker-compose exec orai bash -c 'oraivisor start --p2p.pex false --p2p.persistent_peers "e6fa2f222236a9ca5e10b238de87eb12497a649c@167.99.119.182:26656,911b290c59a4d3248534b53bdbc8dd4615bb5870@167.99.119.182:26656,35c1f999d67de56736b412a1325370a8e2fdb34a@5.189.169.99:26656,5ad3b29bf56b9ba95c67f282aa281b6f0903e921@64.225.53.108:26656"'
#✋ 🍺🍺🍺 WAIT UNTIL YOUR NODE IS SYNCHRONIZED 🍺🍺🍺
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#👉 Recover node information
#🛑 /mnt/orai/.oraid/config/priv_validator_key.json
#🛑 /mnt/orai/.oraid/config/node_key.json
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#       👆 OR 👇
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🚀 Create validator transaction (inside of the container)
#⛔ make 2orai over naar de Vallet
#⛔ docker-compose exec orai bash
#⛔ wget -O /usr/bin/fn https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/fn.sh && chmod +x /usr/bin/fn && fn createValidator
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
