#!/bin/bash

set +e

GREEN='\033[0;32m'
NC='\033[0m'

msg() {
echo -e "${GREEN}### $*${NC}"
}

APT_PACKAGES=(
    snapd gparted krusader filezilla grub-customizer doublecmd-qt ark cups
    system-config-printer hplip
)

SNAP_PACKAGES=(
    onlyoffice-desktopeditors sublime-text brave code
)

install_packages() {
    local manager="$1"
    shift

    for pkg in "$@"; do
        msg "Installing $pkg"

        if [[ "$manager" == "apt" ]]; then
            sudo apt install -y "$pkg"
        else
            sudo snap install "$pkg" --classic
        fi
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
install_packages apt "${APT_PACKAGES[@]}"

sudo systemctl enable --now snapd.socket
install_packages snap "${SNAP_PACKAGES[@]}"

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
# Remove LibreOffice
# --------------------------------------------------
# msg "Remove LibreOffice"
# sudo apt purge 'libreoffice*' -y
# sudo apt autoremove -y

# --------------------------------------------------
# Add Printer
# --------------------------------------------------
PRINTER_IP="192.168.0.248"
PRINTER_NAME="HP_M402dw"

msg "Install printer"

sudo systemctl enable --now cups
if ! lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
    sudo lpadmin \
        -p "$PRINTER_NAME" \
        -E \
        -v "ipp://$PRINTER_IP/ipp/print" \
        -m everywhere
fi

sudo lpoptions -d "$PRINTER_NAME"

# Show printers
lpstat -p

msg "DONE"
snap list 
snap find onlyoffice
