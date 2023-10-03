#!/bin/bash

# oraichanin network
PORT="266"
PEERS="$(curl -sS https://rpc.oraichain.hexnodes.co/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
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

pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.oraid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.oraid/config/app.toml
