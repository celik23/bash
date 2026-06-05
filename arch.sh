
#!/usr/bin/env bash
#
set +e     # Continue on error

echo "### 💻 CachyOS / Arch Linux "
sudo pacman -Syu --noconfirm

# Paru installeren indien nodig
if ! command -v paru >/dev/null 2>&1; then
    echo "### Install paru"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (
        cd /tmp/paru
        makepkg -si --noconfirm
    )
fi
echo "### $(paru --version | head -1)"

# function pacman/paru
install() {
    local manager="$1"
    shift

    local GREEN='\033[0;32m'
    local NC='\033[0m'
    
    for pkg in "$@"; do
        echo -e "${GREEN}Installing $manager${NC} $pkg ..."

        if [[ "$manager" == "pacman" ]]; then
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            paru -S --needed --noconfirm "$pkg"
        fi
    done
}

pac_packages=(
    dolphin kate nano kio-admin git htop flatpak wget curl ark gparted keepassxc
    chromium filezilla mpv ffmpeg code discover ntfs-3g exfatprogs
)

aur_packages=(
    onlyoffice-bin sublime-text
)

install pacman "${pac_packages[@]}"
install paru "${aur_packages[@]}"


echo -e "\e[32m# Autostart\e[0m Script"
sudo tee ~/start-browser-link.sh >/dev/null <<EOF
#!/bin/bash
firefox "http://192.168.0.64:8888/" "http://192.168.0.64:3001"
EOF
sudo chmod +x ~/start-browser-link.sh

# KDE Menu > System > System settings > (System) Autostart > Add New > Login Script > ~/start-browser-link.sh 
echo -e "\e[32m# Autostart\e[0m monitoring"
mkdir -p ~/.config/autostart
sudo tee ~/.config/autostart/start-browser-link.sh.desktop >/dev/null <<EOF
[Desktop Entry]
Exec=~/start-browser-link.sh
Icon=application-x-shellscript
Name=firefox-start-browser-link.sh
Type=Application
X-KDE-AutostartScript=true
EOF

# KDE Menu > System > System Settings > Login Screen > Automatically log in: ✅ as user: kaan
echo -e "\e[32m# Autologin\e[0m kde plasma"
sudo tee /etc/plasmalogin.conf >/dev/null <<EOF
[Autologin]
Session=plasma.desktop
User=kaan
EOF

echo -e "\e[32m# Printer\e[0m HP_402dw"
#1. Install and start CUPS
sudo pacman -S cups cups-pdf system-config-printer
sudo systemctl enable --now cups

#2. HP drivers
sudo pacman -S --noconfirm hplip

#3. Add print
sudo lpadmin -p HP_M402dw -E \
  -v ipp://192.168.0.248/ipp/print \
  -m everywhere

#4. Set default print
sudo lpoptions -d HP_M402dw

#

