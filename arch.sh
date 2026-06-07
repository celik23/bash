#!/usr/bin/env bash
#
set +e   # Continue on error

# --------------------------------------------------
# Config
# --------------------------------------------------
PRINTER_IP="192.168.0.248"
PRINTER_NAME="HP_M402dw"

PAC_PACKAGES=(
    dolphin kate nano kio-admin git htop flatpak wget curl ark
    gparted keepassxc chromium filezilla mpv ffmpeg code
    discover ntfs-3g exfatprogs krusader rsync
)

AUR_PACKAGES=(
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

        if [[ "$manager" == "pacman" ]]; then
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            paru -S --needed --noconfirm "$pkg"
        fi
    done
}

install_paru() {
    command -v paru >/dev/null && return
    msg "Installing paru ..."
    sudo pacman -S --needed --noconfirm git base-devel

    rm -rf /tmp/paru
    git clone https://aur.archlinux.org/paru.git /tmp/paru

    (
        cd /tmp/paru
        makepkg -si --noconfirm
    )
}

# --------------------------------------------------
# System update
# --------------------------------------------------
msg "Update Arch Linux"
sudo pacman -Syu --noconfirm

# --------------------------------------------------
# paru
# --------------------------------------------------
install_paru
msg "$(paru --version | head -1)"

# --------------------------------------------------
# Packages
# --------------------------------------------------
install_packages pacman "${PAC_PACKAGES[@]}"
install_packages paru "${AUR_PACKAGES[@]}"

# --------------------------------------------------
# Autostart browser
# --------------------------------------------------
msg "Autostart browser"
mkdir -p "$HOME/.config/autostart"
sudo tee $HOME/.config/autostart/start-browser-link.desktop >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Firefox
Exec=/bin/bash -c "sleep 5 && firefox http://192.168.0.64:8888/ http://192.168.0.64:3001/"
EOF

# --------------------------------------------------
# KDE Autologin
# --------------------------------------------------
msg "KDE autologin"
sudo tee /etc/plasmalogin.conf >/dev/null <<EOF
[Autologin]
User=$USER
Session=plasma.desktop
EOF

# --------------------------------------------------
# Printer
# --------------------------------------------------
msg "Install printer"
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

# --------------------------------------------------
# 24h
# --------------------------------------------------
msg "Setting locale (24h time)..."

sudo sed -i 's/#nl_NL.UTF-8 UTF-8/nl_NL.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen

cat <<EOF | sudo tee /etc/locale.conf
LANG=en_US.UTF-8
LC_TIME=nl_NL.UTF-8
EOF

export LC_TIME=nl_NL.UTF-8
export LANG=en_US.UTF-8

# --------------------------------------------------
# Done
# --------------------------------------------------
msg "DONE"
#
