#!/bin/bash

echo -e "\n\e[1;33m           A V A I L  B I N A R Y  I N S T A L L   F O R   U B U N T U   2 3 . 0 4"
echo -e "\e[0m"

# variable / input
TAG=2304

default=${TAG}
read -p "Please enter VERSION [$default]: " TAG
TAG=${TAG:-$default}

default=${ALIAS}
read -p "Please enter your ALIAS-NAME [$default]: " ALIAS
ALIAS=${ALIAS:-$default}

echo -e "Verify the information below before proceeding with the installation!\n"
echo -e "ALIAS        : $ALIAS"
echo -e "ALIAS        : $TAG"
echo -e "\n"

read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
#👉 environment variables
	echo export 'PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
	echo export 'ALIAS=$ALIAS' >> ~/.bash_profile
	source ~/.bash_profile
else
	echo "Installation cancelled!"
	exit 1
fi

#🔖 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#⚠️⚠️ install ubuntu 23.04 ⚠️⚠️
lsb_release -a
sudo apt update -y

# Install necessary dependencies / requirements
sudo apt install git curl screen -y

# Download and extract binary
wget https://github.com/availproject/avail/releases/download/v1.8.0.4/x86_64-ubuntu-${TAG}-data-avail.tar.gz
tar xvzf x86_64-ubuntu-2304-data-avail.tar.gz && rm ./x86_64-ubuntu-${TAG}-data-avail.tar.gz

# run avail or start from services
# /root/data-avail -d ./output --chain goldberg --validator --name "$ALIAS"

# Make service
sudo tee /etc/systemd/system/availd.service > /dev/null <<EOF
[Unit] 
Description=Avail Validator
After=network.target
StartLimitIntervalSec=0
[Service] 
User=root 
ExecStart=/root/data-avail -d ./output --chain goldberg --validator --name "$ALIAS"
Restart=always 
RestartSec=120
[Install] 
WantedBy=multi-user.target
EOF

#🔖 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Reload systemd manager configuration.
systemctl daemon-reload 

#To enable this to autostart on bootup run:
systemctl enable availd

#Start it manually with:
systemctl start availd

#You can check that it''s working with:
systemctl status availd

echo -e "check: journalctl -f -u availd"

