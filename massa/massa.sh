#!/bin/bash
#
# // Copyright (C) 2023-2024
#
# input password
default=${PASSWORD}
read -p "Please enter your massa-client password [$default]: " PASSWORD
PASSWORD=${PASSWORD:-$default}

# set environment variables
echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\h:\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
echo "export PASSWORD='${PASSWORD}'" >> $HOME/.bash_profile 
source $HOME/.bash_profile

# install dependencies
sudo apt -qy update && sudo apt -qy upgrade
sudo apt -qy install curl git jq lz4 build-essential fail2ban ufw

# find CPU architecture
OS=$([[ $(uname -m) == "aarch64" ]] && echo "_arm64" || echo "")

# install and init app
export VER=2.4
FILE="massa_MAIN.${VER}_release_linux${OS}.tar.gz"
URL="https://github.com/massalabs/massa/releases/download/MAIN.${VER}/${FILE}"
wget "${URL}" -O $HOME/${FILE}
tar -xvf $HOME/${FILE} -C $HOME/
chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client 

# download config file
wget -O $HOME/massa/massa-node/config/config.toml https://files.pulsr.nl/massa/node-config.toml
wget -O $HOME/massa/massa-client/config/config.toml https://files.pulsr.nl/massa/client-config.toml

#👉 services
sudo tee /etc/systemd/system/massad.service > /dev/null <<EOF
[Unit]
Description=Massa Daemon
After=network-online.target
[Service]
Environment="RUST_BACKTRACE=full"
WorkingDirectory=$HOME/massa/massa-node
User=$USER
ExecStart=$HOME/massa/massa-node/massa-node -p "${PASSWORD}" 
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF

# start services
systemctl daemon-reload
systemctl enable massad

sudo systemctl restart massad && sudo journalctl -fu massad -o cat 

