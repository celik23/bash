#!/bin/bash

set +e

GREEN='\033[0;32m'
NC='\033[0m'

msg() {
echo -e "${GREEN}### $*${NC}"
}

PACKAGES=(
    snapd gparted krusader filezilla grub-customizer doublecmd-qt ark cups
    system-config-printer hplip
)

install_packages() {
    for pkg in "$@"; do
        msg "Installing $pkg"
        sudo apt install -y "$pkg"
    done
}

# --------------------------------------------------
# Update system
# --------------------------------------------------
msg "Updating system"
sudo apt update
sudo apt upgrade -y

# --------------------------------------------------
# Install packages
# --------------------------------------------------
install_packages "${PACKAGES[@]}"

# --------------------------------------------------

# Enable snap
# --------------------------------------------------
msg "Enable snap"
sudo systemctl enable --now snapd.socket

# --------------------------------------------------
# Set Dutch locale
# --------------------------------------------------
msg "Set locale"
grep -q '^LC_TIME=' /etc/default/locale ||
echo 'LC_TIME=nl_NL.UTF-8' | sudo tee -a /etc/default/locale

# --------------------------------------------------
# Configure SDDM autologin (KDE)
# --------------------------------------------------
msg "Configure autologin"
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null <<EOF
[Autologin]
User=$USER
Session=plasma
EOF

# --------------------------------------------------
# Sublime Text repository
# --------------------------------------------------
msg "Install Sublime Text"
sudo mkdir -p /etc/apt/keyrings
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg
| gpg --dearmor
| sudo tee /etc/apt/keyrings/sublime.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/sublime.gpg] https://download.sublimetext.com/ apt/stable/"
| sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt update
sudo apt install -y sublime-text

# --------------------------------------------------
# Remove LibreOffice
# --------------------------------------------------
msg "Remove LibreOffice"
sudo apt purge 'libreoffice*' -y
sudo apt autoremove -y

# --------------------------------------------------
# Printer
# --------------------------------------------------
PRINTER_IP="192.168.0.248"
PRINTER_NAME="HP_M402dw"

msg "Install printer"

sudo systemctl enable --now cups
sudo lpadmin
    -p "$PRINTER_NAME"
    -E
    -v "ipp://$PRINTER_IP/ipp/print"
    -m everywhere

sudo lpoptions -d "$PRINTER_NAME"

msg "DONE"
