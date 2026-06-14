
#!/bin/bash
#
# // Copyright (C) 2026
set +e     # Continue on error

# --------------------------------------------------
# Config
# --------------------------------------------------
PAC_PACKAGES=(
    snapd gparted dolphin krusader filezilla grub-customizer doublecmd-qt6 ark
)

SNAP_PACKAGES=(
    onlyoffice-bin sublime-text brave-bin
)

# --------------------------------------------------
# Helpers
# --------------------------------------------------
GREEN='\033[0;32m'
NC='\033[0m'

msg() {
    echo -e "${GREEN}### $*${NC}"
}

install_packages() {
    local manager="$1"
    shift

    for pkg in "$@"; do
        msg "Installing $pkg"

        if [[ "$manager" == "apt" ]]; then
            sudo apt -y install "$pkg"
        else
            snap apt -y install "$pkg"
        fi
    done
}


# --------------------------------------------------
# System update
# --------------------------------------------------
sudo apt update -y && sudo apt upgrade -y

install_packages apt "${PAC_PACKAGES[@]}"
install_packages snap "${SNAP_PACKAGES[@]}"

msg "# Setting Monday as the First Day"
msg 'LC_TIME=nl_NL.UTF-8' | sudo tee -a /etc/default/locale

msg "# Configure automatic login"
sudo sed -i \
    -e 's/^\s*#\?\s*AutomaticLoginEnable\s*=.*/AutomaticLoginEnable = true/' \
    -e 's/^\s*#\?\s*AutomaticLogin\s*=.*/AutomaticLogin = kaan/' \
    /etc/gdm3/daemon.conf

msg "# Sublime Text"
sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
msg -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt install sublime-text

msg "# Uninstall libreoffice"
sudo apt purge 'libreoffice*' -y
sudo apt autoremove -y
sudo apt clean

# --------------------------------------------------
# Printer
# --------------------------------------------------
PRINTER_IP="192.168.0.248"
PRINTER_NAME="HP_M402dw"

msg "Install printer $PRINTER_NAME"
sudo pacman -S --needed --noconfirm \
    cups \
    system-config-printer \
    hplip

sudo systemctl enable --now cups

sudo lpadmin \
    -p "$PRINTER_NAME" \
    -E \
    -v "ipp://$PRINTER_IP/ipp/print" \
    -m everywhere

sudo lpoptions -d "$PRINTER_NAME"

msg "DONE"
#
