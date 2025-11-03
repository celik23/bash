#!/bin/bash
#
# // Copyright (C) 2025
#
# setup gonme
# Setting Monday as the First Day
echo 'LC_TIME=nl_NL.UTF-8' | sudo tee -a /etc/default/locale

# Configure automatic login
sudo sed -i \
    -e 's/^\s*#\?\s*AutomaticLoginEnable\s*=.*/AutomaticLoginEnable = true/' \
    -e 's/^\s*#\?\s*AutomaticLogin\s*=.*/AutomaticLogin = kaan/' \
    /etc/gdm3/daemon.conf

### snapd ###
sudo apt update -y
sudo apt upgrade -y

# KDE Partition Manager
sudo apt install partitionmanager -y

# File manager krusader
sudo apt install krusader -y

# Filezilla
sudo apt install filezilla -y 

# Printer services
sudo apt install cups
sudo apt install printer-driver-cups-pdf
sudo systemctl start cups
sudo systemctl enable cups
# Settings > Printers > Unlock > HP_LaserJet_M402dw_AF41C3

# Google-chrome-stable
sudo apt install google-chrome-stable -y
# sudo apt purge google-chrome-stable

#VSCode
sudo apt install code -y

# Sublime Text
sudo apt install sublime-text -y

# Install Grub Customizer
sudo apt install grub-customizer -y

###
# Install snap
sudo apt install snapd -y
sudo snap install snapd


# Brave
sudo snap install brave

# KeePassXC
sudo snap install keepassxc

# Firefox lates
sudo snap install firefox

# Firefox update
#sudo snap refresh firefox


lsblk
sudo fdisk -l

# File manager
# Ctrl + Alt + T
# nautilus admin:/

# superfile
# bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"

# yazi
# apt install ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick

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
