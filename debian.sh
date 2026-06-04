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

echo "# File manager dolphin"
sudo apt install dolphin -y

echo "# File manager krusader"
sudo apt install krusader -y

echo "# Filezilla"
sudo apt install filezilla -y 

echo "# Install Grub Customizer"
sudo apt install grub-customizer -y

echo "# Sublime Text"
sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt install sublime-text

echo "# Uninstall libreoffice"
sudo apt parge "libreoffice*" -y
sudo apt autoremove -y
sudo apt clean

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

echo "# Install onlyoffice"
sudo snap install onlyoffice-desktopeditors

###
echo "# Install Flatpak"
# sudo apt install flatpak
# flatpak remote-add --if-not-exists flathub https://flathub.org
# flatpak install flathub org.onlyoffice.desktopeditors

echo "# Printer services"
sudo apt install -y cups printer-driver-cups-pdf
sudo systemctl start cups
sudo systemctl enable cups
echo "# Settings > Printers > Unlock > HP_M402dw"

#
