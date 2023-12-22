#!/bin/bash
#
# // Copyright (C) 2023 
#

# Define screen colors:
RED='\e[0;31m'; CYAN='\e[1;36m'; MAGENTA='\e[0;32m'; BLUE='\e[1;34m'; GREEN='\e[1m\e[35m'; NC='\e[0m';

# Input
default=${VALIDATOR_ALIAS}
read -p "Please enter your moniker name [$default]: " VALIDATOR_ALIAS
VALIDATOR_ALIAS=${VALIDATOR_ALIAS:-$default}

default=${PASSWORD}
read -p "Please enter your password [$default]: " PASSWORD
PASSWORD=${PASSWORD:-$default}

echo "Verify the information below before proceeding with the installation!\n"
echo -e "VALIDATOR_ALIAS : ${MAGENTA}$VALIDATOR_ALIAS${NC}"
echo -e "PASSWORD        : ${MAGENTA}$PASSWORD${NC}"
echo -e "${MAGENTA}Recover validator & wallte files!${NC}"

# environment variables 🍒
read -p "Is the above information correct? (y/n) " choice
if [[ $choice == [Yy]* ]]; then
  echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
  echo "export VALIDATOR_ALIAS='$VALIDATOR_ALIAS'" >> ~/.bash_profile
  echo "export PASSWORD='$PASSWORD'" >> ~/.bash_profile
  echo 'export CHAIN_ID=public-testnet-14.5d79b6958580' >> ~/.bash_profile
  source $HOME/.bash_profile
else
    read -p "Are you sure you want to cancel the installation? (y/n) " choice
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
tar -xvf $HOME/${latest} --strip-components 1 -C $HOME/.cargo/bin/ && rm -rf $HOME/${latest}

# Make namadad.service
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=NAMADA_LOG=info
Environment=CMT_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=$HOME/.cargo/bin/namada node ledger run
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable namadad
sleep 2.5

# Only for PRE-GENESIS validator || if you not a pre gen validator skip this section
namadac utils join-network --chain-id $CHAIN_ID
sleep 2.5

sudo systemctl enable namadad

journalctl -u namadad -f -o cat 
