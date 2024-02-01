#!/bin/bash
#
# // Copyright (C) 2023 
#

# Define screen colors:
RED='\e[0;31m'; CYAN='\e[1;36m'; GREEN='\e[0;32m'; BLUE='\e[1;34m'; MAGENTA='\e[1m\e[35m'; NC='\e[0m';

# Input
default=${MONIKER}
read -p "Please enter your moniker-name [$default]: " MONIKER
MONIKER=${MONIKER:-$default}

default=${WALLLET}
read -p "Please enter your wallet-name [$default]: " WALLLET
WALLLET=${WALLLET:-$default}

default=${CHAIN_ID}
read -p "Please enter CHAIN ID  [$default]: " CHAIN_ID
CHAIN_ID=${CHAIN_ID:-$default}

echo "Verify the information below before proceeding with the installation!\n"
echo -e "CHAIN_ID   : ${GREEN}$CHAIN_ID${NC}"
echo -e "MONIKER    : ${GREEN}$MONIKER${NC}"
echo -e "WALLLET    : ${GREEN}$WALLLET${NC}"
echo -e "${MAGENTA}Recover validator & wallte files!${NC}"

# environment variables 🍒
read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
  echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
  echo "export MONIKER='$MONIKER'" >> ~/.bash_profile
  echo "export WALLLET='$WALLLET'" >> ~/.bash_profile
  echo "export CHAIN_ID=$CHAIN_ID" >> ~/.bash_profile
  source $HOME/.bash_profile
else
    read -p "Are you sure you want to cancel the installation? (y/N) " choice
    if [[ $choice == [Yy]* ]]; then
      echo "Installation cancelled!"
      exit 1
    fi
fi

# Install necessary dependencies / requirements
sudo apt update -y
sudo apt install -y curl jq expect

tag=0.37.2
wget -O $HOME/cometbft.tar.gz "https://github.com/cometbft/cometbft/releases/download/v${tag}/cometbft_${tag}_linux_amd64.tar.gz"
tar -xvf $HOME/cometbft.tar.gz --strip-components 0 -C /usr/local/bin/ && rm -rf $HOME/cometbft.tar.gz 

# install namada
OS="Linux" # or "Darwin" for MacOS
URL="https://api.github.com/repos/anoma/namada/releases/latest"
URL=$(curl -s ${URL} | grep "browser_download_url" | cut -d '"' -f 4 | grep "$OS")
latest="$(basename -a $URL)" && wget "$URL" -O $HOME/${latest}
tar -xvf $HOME/${latest} --strip-components 1 -C /usr/local/bin && rm -rf $HOME/${latest}

# Make service
tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=CMT_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Only for PRE-GENESIS validator || if you not a pre gen validator skip this section
namadac utils join-network --chain-id $CHAIN_ID 
# --pre-genesis-path $HOME/.local/share/namada/pre-genesis/$MONIKER
sleep 2.5

sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl start namadad
sleep 2.5

sudo journalctl -u namadad -f -o cat 
