#!/bin/bash
#
# // Copyright (C) 2023 
#

echo -e "\033[0;32m"
echo -e "\t\t\t Automatic Installer for Oraichain | Chain ID : Oraichain ";
echo -e "\e[0m"

# constant
SOURCE=orai
CHAIN_ID=Oraichain
FOLDER=.oraid
VERSION=v0.41.3
DENOM=orai
REPO=https://github.com/oraichain/orai
PORT=266

# variable
default="MONIKER NAME"
read -p "Please enter your [$default]: " MONIKER
MONIKER=${MONIKER:-$default}

default="Oraichain_12715288.tar.lz4"
read -p "Enter new  snapshot name [$default]: " SNAPSHOTS
SNAPSHOTS=${SNAPSHOTS:-$default}

echo "Verify the information below before proceeding with the installation!"
echo ""
echo -e "MONIKER        : \e[1m\e[35m$MONIKER\e[0m"
echo -e "CHAIN ID       : \e[1m\e[35m$CHAIN_ID\e[0m"
echo -e "NODE VERSION   : \e[1m\e[35m$VERSION\e[0m"
echo -e "NODE FOLDER    : \e[1m\e[35m$FOLDER\e[0m"
echo -e "NODE DENOM     : \e[1m\e[35m$DENOM\e[0m"
echo -e "SOURCE CODE    : \e[1m\e[35m$REPO\e[0m"
echo -e "NODE PORT      : \e[1m\e[35m$PORT\e[0m"
echo -e "SNAPSHOTS      : \e[1m\e[35m$SNAPSHOTS\e[0m"
echo ""

read -p "Is the above information correct? (y/n) " choice
if [[ $choice == [Yy]* ]]; then

    echo "export SOURCE=${SOURCE}" 
    echo "export WALLET=${MONIKER}" 
    echo "export DENOM=${DENOM}" 
    echo "export CHAIN_ID=${CHAIN_ID}" 
    echo "export FOLDER=${FOLDER}"
    echo "export VERSION=${VERSION}"
    echo "export REPO=${REPO}" 
    echo "export PORT=${PORT}"
    source $HOME/.bash_profile

else
    echo "Installation cancelled!"
    exit 1
fi

#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🏀 install docker and docker-compose
wget -O docker-ubuntu.sh https://github.com/celik23/bash/raw/main/docker-ubuntu.sh && chmod +x docker-ubuntu.sh && ./docker-ubuntu.sh

#🏀 install recommended apps
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common lz4 jq

#🏀 Edit orai.env | docker-compose.yml
curl -OL https://raw.githubusercontent.com/celik23/bash/main/docker-compose.yml && curl -OL https://raw.githubusercontent.com/celik23/bash/main/orai.env

docker-compose pull && docker-compose up -d --force-recreate

# Download Chain Data
mkdir $HOME/.oraid
curl -L https://snapshots.nysa.network/Oraichain/$SNAPSHOTS | tar -Ilz4 -xf - -C $HOME/.oraid
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
docker exec -it orai_node /bin/bash -c 'oraid init $MONIKER --chain-id "$CHAIN_ID"'
#⛔ oraid keys add $MONIKER 2>&1 | tee account.txt && exit
#       👆 OR 👇
#👉 import exist wallet (recover wallet)
docker exec -it orai_node /bin/bash -c 'oraid keys add $MONIKER --recover'

#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# Download genesis.json
wget -O $HOME/.oraid/config/genesis.json https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/genesis.json

# Netwrok setup | Replace config.toml and app.toml
wget -O $HOME/oraichain-network.sh https://github.com/celik23/bash/raw/main/oraichain-network.sh && chmod +x oraichain-network.sh && $HOME/oraichain-network.sh
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🛑 screen -ls #list-session | screen -S <new-session-name> | screen -r <session-name> | screen -d -r 27863
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
#    make 2orai over naar de Vallet
#⛔ docker-compose exec orai bash
#⛔ wget -O /usr/bin/fn https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/fn.sh && chmod +x /usr/bin/fn && fn createValidator
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
