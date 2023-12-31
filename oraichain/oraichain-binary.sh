# https://github.com/konsortech/Node/blob/9995bff7ff771b8ea9d19066eb0cc083db7a5d62/Mainnet/Orai/readme.md?plain=1#L47

#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# environment variables
echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
echo 'export VERSION=0.41.5' >> ~/.bash_profile
echo 'export MONIKER=Andromeda' >> ~/.bash_profile
echo "export WALLET=wallet" >> ~/.bash_profile
echo 'export CHAIN_ID=Oraichain' >> ~/.bash_profile
source ~/.bash_profile

#!/bin/bash
#
# // Copyright (C) 2023 
#
# constant
CHAIN_ID=Oraichain
FOLDER=.oraid
REPO=https://github.com/oraichain/orai
PORT=266

# define screen colors:
RED='\e[0;31m'; CYAN='\e[1;36m'; GREEN='\e[0;32m'; BLUE='\e[1;34m'; PINK='\e[1m\e[35m'; NC='\e[0m';

echo -e "${CYAN} \t\t Automatic Installer for Oraichain | Chain ID : $CHAIN_ID ${NC}";

# variable / input
default=$MONIKER
read -p "Please enter your MONIKER NAME [$default]: " MONIKER
MONIKER=${MONIKER:-$default}

default=${VERSION}
read -p "Please enter docker pull version [$default]: " VERSION
VERSION=${VERSION:-$default}

default="Oraichain_13771328.tar.lz4"
echo -e "${GREEN}Check voor new snapshot version: https://snapshots.nysa.network/Oraichain/#Oraichain/${NC}"
read -p "Enter new snapshot name [$default]: " SNAPSHOTS
SNAPSHOTS=${SNAPSHOTS:-$default}

echo "\nVerify the information below before proceeding with the installation!\n"
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


# Install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl build-essential git wget jq make gcc tmux net-tools ccze make lz4 ufw -y

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
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi


# Download and build binaries
cd $HOME && rm -rf orai
git clone https://github.com/oraichain/orai.git && cd orai
git checkout ${VERSION}
cd ./orai
make install


# Config app
oraid init $MONIKER --chain-id $CHAIN_ID --home "$HOME/.oraid"
oraid keys add $MONIKER --recover

# Download configuration
cd $HOME
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
mkdir -p $HOME/.oraid/config
curl -L https://snapshots.nysa.network/Oraichain/Oraichain_15076936.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.oraid

# Register and start service
sudo systemctl daemon-reload
sudo systemctl enable oraid
sudo systemctl restart oraid && sudo journalctl -u oraid -f -o cat

