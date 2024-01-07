#!/bin/bash
#
# // Copyright (C) 2023-2024
#

# Define screen colors:
red="\e[0;31m"; cyan="\e[1;36m"; green="\e[0;32m"; blue="\e[1;34m"; magenta="\e[1m\e[35m"; nc="\e[0m";

# variable | input
default=${nodename}
read -p "Please enter your massa-client nodename [$default]: " nodename
nodename=${nodename:-$default}

default=${password}
read -p "Please enter your massa-client password [$default]: " password
password=${password:-$default}

echo -e "\n${cyan}Verify the information below before proceeding with the installation!${nc}"
echo -e "Nodename   : ${green}$nodename${nc}"
echo -e "Password   : ${green}$password${nc}"

read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
    # environment variables
    echo "export PS1='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] '" >> ~/.bash_profile
    echo "export password='${password}'" >> ~/.bash_profile 
    echo "export password='${password}'" >> ~/.bash_profile 
    source ~/.bash_profile
else
    echo -e "${red}Installation cancelled!${nc}"
    exit 1
fi

#🔖 -------------------------------------
#🏁 Install necessary dependencies/requirements
sudo apt update
sudo apt install -y curl
# sudo apt install git pkg-config curl build-essential libssl-dev libclang-dev cmake screen cron nano

# find CPU architecture
systemctl stop massad.service 
if [ $(uname -m) == "aarch64" ]; then
    OS="linux_arm64.tar"
else
    OS="linux.tar"
fi

# install app
url="https://api.github.com/repos/massalabs/massa/releases/latest"
url=$(curl -s ${url} | grep "browser_download_url" | cut -d '"' -f 4 | grep ${OS})
latest="$(basename -a ${url})" && wget "${url}" -O $HOME/${latest}
tar -xvf ${latest} -C $HOME/ && rm $HOME/${latest}
chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client 
echo "${latest}" >> "${latest}.txt" 

wget -O $HOME/massa/massa-node/config/config.toml https://raw.githubusercontent.com/celik23/bash/main/massa/node-config.toml
wget -O $HOME/massa/massa-client/config/config.toml https://raw.githubusercontent.com/celik23/bash/main/massa/client-config.toml

#👉 services
sudo tee /etc/systemd/system/massad.service > /dev/null <<EOF
[Unit]
Description=Massa Daemon
After=network-online.target

[Service]
Environment="RUST_BACKTRACE=full"
WorkingDirectory=$HOME/massa/massa-node
User=$USER
ExecStart=$HOME/massa/massa-node/massa-node -p "${password}" 
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# start services
systemctl daemon-reload 
systemctl enable massad 
systemctl restart massad && journalctl -u massad -f -o cat 
#
