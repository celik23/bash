#!/bin/bash
#
# // Copyright (C) 2025
#
# Setting Monday as the First Day
echo 'LC_TIME=nl_NL.UTF-8' | sudo tee -a /etc/default/locale

# Configure automatic login
sudo sed -i "/AutomaticLoginEnable =/, /AutomaticLogin =/ {
  s|AutomaticLoginEnable =.*|AutomaticLoginEnable = true|;
  s|AutomaticLogin =.*|AutomaticLogin = kaan|;
}" /etc/gdm3/daemon.conf

# KDE Partition Manager
sudo apt install partitionmanager -y

# Printer services
sudo apt update -y
sudo apt install cups
sudo apt install printer-driver-cups-pdf
sudo systemctl start cups
sudo systemctl enable cups
# Settings > Printers > Unlock > HP_LaserJet_M402dw_AF41C3

# google-chrome
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome*.deb
# sudo apt-get install -f

# Brave
sudo apt update -y
sudo apt install snapd
sudo snap install snapd
sudo snap install brave

#vscode
sudo apt update -y
sudo apt upgrade -y
sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https curl -y
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg >/dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update -y
sudo apt install code
sudo apt install code-insiders

# Sublime Text - Text Editing, Done Right
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt update -y
sudo apt install sublime-text

# Install Grub Customizer
sudo apt install grub-customizer -y
lsblk
sudo fdisk -l

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
