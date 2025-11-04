#!/bin/bash
#
# // Copyright (C) 2025
#
# setup gonme
sudo apt update -y
sudo apt upgrade -y

# Setting Monday as the First Day
echo 'LC_TIME=nl_NL.UTF-8' | sudo tee -a /etc/default/locale

# Configure automatic login
sudo sed -i \
    -e 's/^\s*#\?\s*AutomaticLoginEnable\s*=.*/AutomaticLoginEnable = true/' \
    -e 's/^\s*#\?\s*AutomaticLogin\s*=.*/AutomaticLogin = kaan/' \
    /etc/gdm3/daemon.conf

# KDE Partition Manager
sudo apt install partitionmanager -y

# File manager krusader
sudo apt install krusader -y

# Filezilla
sudo apt install filezilla -y 

# Install Grub Customizer
sudo apt install grub-customizer -y

# Printer services
sudo apt install cups
sudo apt install printer-driver-cups-pdf
sudo systemctl start cups
sudo systemctl enable cups
# Settings > Printers > Unlock > HP_LaserJet_M402dw_AF41C3

# Google-Chrome
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome*.deb

# VSCode install
# 1. Import Microsoft’s GPG key
sudo wget -qO /usr/share/keyrings/microsoft.gpg https://packages.microsoft.com/keys/microsoft.asc

# 2. Add the VS Code repository
sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null << 'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

# 3. Update package lists and install VS Code
sudo apt update
sudo apt install code

# Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt update
sudo apt install sublime-text


###
# Install snap
sudo apt install snapd -y
sudo snap install snapd

# Brave
sudo snap install brave

# KeePassXC
sudo snap install keepassxc

# Firefox
sudo snap install firefox

lsblk
sudo fdisk -l

# File manager
# Ctrl + Alt + T
# nautilus admin:/

# superfile
# bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"

# # mount
# sudo mount -o rw,remount /boot/efi
# sudo mkdir /mnt/efi
# sudo mount /dev/sda1 -t vfat /mnt
# cd /mnt/efi

# # unmount
# sudo unmount /dev/sda1

# # NVRAM entry to boot.
# sudo efibootmgr -v
# sudo efibootmgr --delete-bootnum --bootnum 3

# Pardus GNOME Greeter
# - Mac Style
# - Pardus Style
