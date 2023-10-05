#!/bin/bash
#
# // Copyright (C) 2023 
#

#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# environment variables
echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
echo 'export ALIAS="Red Apple"' >> ~/.bash_profile
echo 'export WALLET="Red Apple"' >> ~/.bash_profile
echo 'export pass="IK!bin23@"' >> ~/.bash_profile
echo 'export RUST_BACKTRACE=full' >> ~/.bash_profile
echo 'export COLORBT_SHOW_HIDDEN=1' >> ~/.bash_profile
echo 'export CHAIN_ID=public-testnet-14.5d79b6958580' >> ~/.bash_profile
source ~/.bash_profile
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# Install necessary dependencies / requirements
sudo apt update -y
sudo apt install curl jq screen expect -y

wget "http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb"
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb && rm -rf $HOME/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
tag=0.37.2
wget -O $HOME/cometbft.tar.gz "https://github.com/cometbft/cometbft/releases/download/v${tag}/cometbft_${tag}_linux_amd64.tar.gz"
tar -xvf $HOME/cometbft.tar.gz --strip-components 0 -C /usr/local/bin/ && rm -rf $HOME/cometbft.tar.gz 
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
OS="Linux" # or "Darwin" for MacOS
URL="https://api.github.com/repos/anoma/namada/releases/latest"
URL=$(curl -s ${URL} | grep "browser_download_url" | cut -d '"' -f 4 | grep "$OS")
latest="$(basename -a $URL)" && wget "$URL" -O $HOME/${latest}
tar -xvf $HOME/${latest} --strip-components 1 -C /usr/local/bin/ && rm -rf $HOME/${latest}

# check version
namada --version
cometbft version

# output:
# Namada v0.23.0
# 0.37.2
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# Make service
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
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

sudo systemctl daemon-reload
sudo systemctl enable namadad
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
mkdir -p $HOME/.local/share/namada/pre-genesis/"$ALIAS"
#👉 !!! Recover wallte to the onder directory !!!
cp $HOME/wallet-bck/*.toml $HOME/.local/share/namada/pre-genesis/"$ALIAS"/
bash -c /root/scripts/rad-apple_validator.sh
cat $HOME/.local/share/namada/pre-genesis/"$ALIAS"/validator.toml

# ONLY for PRE genesis validator | IF YOU NOT A PRE GEN VALIDATOR SKIP THIS SECTION
cd $HOME && namada client utils join-network \
  --chain-id "$CHAIN_ID" \
  --genesis-validator "$ALIAS"

reboot
