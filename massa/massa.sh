#!/bin/bash
#
# // Copyright (C) 2023 
#

#🔖 —————————————————————————————————————
# Environment variables 🍒
if [[ -z "${PASSWORD}" ]]; then
	echo -e "env: password is undefined!"
	echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
	echo 'export PASSWORD=B!N453han@' >> ~/.bash_profile 
else
	echo -e "env: is defined."
fi
source ~/.bash_profile 
#🔖 —————————————————————————————————————
#🏁 Install necessary dependencies/requirements
sudo apt update
sudo apt install pkg-config curl git build-essential libssl-dev libclang-dev cmake screen cron nano

OS="linux.tar" # or "linux_arm64.tar"
URL="https://api.github.com/repos/massalabs/massa/releases/latest"
URL=$(curl -s ${URL} | grep "browser_download_url" | cut -d '"' -f 4 | grep ${OS})
latest="$(basename -a ${URL})" && wget "${URL}" -O $HOME/${latest}
tar -xvf ${latest} -C $HOME/ && rm $HOME/${latest}
chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client 
echo -e -n "${msg}" >> "${latest}.txt" 

sudo tee /root/massa/massa-node/config/config.toml > /dev/null <<EOF
[network]
routable_ip ="$(curl ifconfig.co)"

[bootstrap]
max_ping = 10000
EOF
sudo nano /root/massa/massa-node/config/config.toml

#🔖 —————————————————————————————————————
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

systemctl daemon-reload 
systemctl enable massad 

systemctl start massad 
systemctl status massad
systemctl stop massad

systemctl restart massad && journalctl -u massad -f -o cat 
# journalctl --unit=massad.service -n 10 --no-pager
