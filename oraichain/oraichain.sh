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

echo -e "${CYAN} \t\t Automatic Installer for Oraichain | Chain ID : $CHAIN_ID ${NC}";

# variable / input
default=$NODENAME
read -p "Please enter your NODENAME [$default]: " NODENAME
NODENAME=${NODENAME:-$default}

default=${VERSION}
read -p "Please enter docker pull version [$default]: " VERSION
VERSION=${VERSION:-$default}

default="Oraichain_13771328.tar.lz4"
echo -e "Check voor new snapshot version:{GREEN} https://snapshots.nysa.network/Oraichain/#Oraichain/${NC}"
read -p "Enter new snapshot name [$default]: " SNAPSHOTS
SNAPSHOTS=${SNAPSHOTS:-$default}

echo "\nVerify the information below before proceeding with the installation!\n"
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
sed -i -e "s/0.41.3/$VERSION/" $HOME/docker-compose.yml

# Build and enter the container
docker-compose pull && docker-compose up -d --force-recreate

# Download Chain Data
mkdir -p $HOME/.oraid/config
curl -L https://snapshots.nysa.network/Oraichain/$SNAPSHOTS | tar -Ilz4 -xf - -C $HOME/.oraid

rm $HOME/.oraid/config/genesis.json
docker exec -it orai_node /bin/bash -c 'oraid init $NODENAME --chain-id "$CHAIN_ID"'
#⛔ oraid keys add $NODENAME 2>&1 | tee account.txt && exit
#       👆 OR 👇
#👉 import exist wallet (recover wallet)
docker exec -it orai_node /bin/bash -c 'oraid keys add $NODENAME --recover'
# Enter keyring passphrase:

# Download genesis.json
wget -O $HOME/.oraid/config/genesis.json https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/genesis.json



# Netwrok setup | Replace config.toml and app.toml
# Set peers and
PORT="266"
PEERS=""
#PEERS="$(curl -sS https://rpc.oraichain.hexnodes.co/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
SEEDS=""

#🏀 Find/Replace | config.toml 
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.oraid/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.oraid/config/config.toml
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}58\"%; 
s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}57\"%; 
s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}60\"%; 
s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}56\"%; 
s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}60\"%" $HOME/.oraid/config/config.toml

#🏀 Find/Replace | app.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001orai\"/" $HOME/.oraid/config/app.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}17\"%; 
s%^address = \":8080\"%address = \":${PORT}80\"%; 
s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}90\"%;
s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}91\"%; 
s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}45\"%; 
s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}46\"%" $HOME/.oraid/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.oraid/config/app.toml


echo "# fix memory leak issue add this to the bottom of app.toml">> $HOME/.oraid/config/app.toml
echo "[wasm]" >> $HOME/.oraid/config/app.toml
echo "query_gas_limit = 300000" >> $HOME/.oraid/config/app.toml
echo "memory_cache_size = 400" >> $HOME/.oraid/config/app.toml

# docker-compose restart orai && docker-compose exec -d orai bash -c 'oraivisor start'
docker-compose restart orai && docker-compose exec orai bash -c 'oraivisor start --p2p.pex false --p2p.persistent_peers "e6fa2f222236a9ca5e10b238de87eb12497a649c@167.99.119.182:26656,911b290c59a4d3248534b53bdbc8dd4615bb5870@167.99.119.182:26656,35c1f999d67de56736b412a1325370a8e2fdb34a@5.189.169.99:26656,5ad3b29bf56b9ba95c67f282aa281b6f0903e921@64.225.53.108:26656"'
#✋ 🍺🍺🍺 WAIT UNTIL YOUR NODE IS SYNCHRONIZED 🍺🍺🍺

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
