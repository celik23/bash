#!/bin/bash
#
# // Copyright (C) 2025
#
echo "# setup gonme"
sudo apt update -y
sudo apt upgrade -y

echo "# Setting Monday as the First Day"
echo 'LC_TIME=nl_NL.UTF-8' | sudo tee -a /etc/default/locale

echo "# Configure automatic login"
sudo sed -i \
    -e 's/^\s*#\?\s*AutomaticLoginEnable\s*=.*/AutomaticLoginEnable = true/' \
    -e 's/^\s*#\?\s*AutomaticLogin\s*=.*/AutomaticLogin = kaan/' \
    /etc/gdm3/daemon.conf

echo "# KDE partition Manager"
# sudo apt install partitionmanager -y

echo "# GNOME partition editor"
sudo apt install gparted -y

echo "# File manager krusader"
sudo apt install krusader -y

echo "# Filezilla"
sudo apt install filezilla -y 

echo "# Install Grub Customizer"
sudo apt install grub-customizer -y

echo "# Printer services"
sudo apt install -y cups printer-driver-cups-pdf
sudo systemctl start cups
sudo systemctl enable cups
echo "# Settings > Printers > Unlock > HP_LaserJet_M402dw_AF41C3"

echo "# Google-Chrome"
sudo apt install libxss1 libappindicator1 libindicator7
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome*.deb

echo "# VSCode install"
echo "# 1. Import Microsoft’s GPG key"
sudo wget -qO /usr/share/keyrings/microsoft.gpg https://packages.microsoft.com/keys/microsoft.asc

echo "# 2. Add the VS Code repository"
sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null << 'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

echo "# 3. Update package lists and install VS Code"
sudo apt install code

echo "# Sublime Text"
sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt install sublime-text


###
echo "# Install snap"
sudo apt install snapd -y
sudo snap install snapd

echo "# Brave"
sudo snap install brave

echo "# KeePassXC"
sudo snap install keepassxc

echo "# Firefox"
# sudo snap install firefox

echo "# VS code"
sudo snap install --classic code

