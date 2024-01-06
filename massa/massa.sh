#!/bin/bash
#
# // Copyright (C) 2023 
#

# Define screen colors:
RED="\e[0;31m"; CYAN="\e[1;36m"; GREEN="\e[0;32m"; BLUE="\e[1;34m"; MAGENTA="\e[1m\e[35m"; NC="\e[0m";

# variable | input
default=${PASSWORD}
read -p "Please enter your massa-client password [$default]: " PASSWORD
PASSWORD=${PASSWORD:-$default}

echo -e "\n${CYAN}Verify the information below before proceeding with the installation!${NC}"
echo -e "Password   : ${GREEN}$PASSWORD${NC}"

read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
    # environment variables
    echo "export PS1='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] '" >> ~/.bash_profile
    echo "export PASSWORD='${PASSWORD}'" >> ~/.bash_profile 
    source ~/.bash_profile
else
    echo -e "${RED}Installation cancelled!${NC}"
    exit 1
fi

#🔖 -------------------------------------
#🏁 Install necessary dependencies/requirements
sudo apt update
sudo apt install -y curl
# sudo apt install git pkg-config curl build-essential libssl-dev libclang-dev cmake screen cron nano

systemctl stop massad.service 

if [ $(uname -m) == "arm64" ]; then
    OS="linux_arm64.tar"
else
    OS="linux.tar"
fi

url="https://api.github.com/repos/massalabs/massa/releases/latest"
url=$(curl -s ${url} | grep "browser_download_url" | cut -d '"' -f 4 | grep ${OS})
latest="$(basename -a ${url})" && wget "${url}" -O $HOME/${latest}
tar -xvf ${latest} -C $HOME/ && rm $HOME/${latest}
chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client 
echo "${latest}" >> "${latest}.txt" 

sudo tee /root/massa/massa-node/config/config.toml > /dev/null <<EOF
[network]
# routable_ip ="$(curl -4 ifconfig.co)"
# routable_ip ="$(curl -6 ifconfig.co)"

[bootstrap]
max_ping = 10000
EOF
sudo nano /root/massa/massa-node/config/config.toml
#🔖 -------------------------------------
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

systemctl daemon-reload 
systemctl enable massad 
systemctl restart massad && journalctl -u massad -f -o cat 

