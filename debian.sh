#!/bin/bash
#
# // Copyright (C) 2025
set +e     # Continue on error
#
echo "# setup gonme"
sudo apt update -y && sudo apt upgrade -y

echo "# Setting Monday as the First Day"
echo 'LC_TIME=nl_NL.UTF-8' | sudo tee -a /etc/default/locale

echo "# Configure automatic login"
sudo sed -i \
    -e 's/^\s*#\?\s*AutomaticLoginEnable\s*=.*/AutomaticLoginEnable = true/' \
    -e 's/^\s*#\?\s*AutomaticLogin\s*=.*/AutomaticLogin = kaan/' \
    /etc/gdm3/daemon.conf


# function pacman/paru
install() {
    local manager="$1"
    shift

    local GREEN='\033[0;32m'
    local NC='\033[0m'
    
    for pkg in "$@"; do
        echo -e "${GREEN}Installing $manager${NC} $pkg ..."

        if [[ "$manager" == "apt" ]]; then
            sudo apt -install -y "$pkg"
        else
            sudo snap -install -y "$pkg"
        fi
    done
}

pac_packages=(
    snapd gparted dolphin krusader filezilla grub-customizer
)

aur_packages=(
    snapd code onlyoffice-desktopeditors
)
# sudo snap install --classic code

install apt "${pac_packages[@]}"
install snap "${aur_packages[@]}"

echo "# Sublime Text"
sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt install sublime-text

echo "# Uninstall libreoffice"
sudo apt parge "libreoffice*" -y
sudo apt autoremove -y
sudo apt clean



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
