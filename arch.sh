
#!/usr/bin/env bash

set -e

echo "### 💻 CachyOS / Arch Linux "
sudo pacman -Syu --noconfirm

#
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
        echo -e "${GREEN}Installing $manager $pkg ...${NC}"

        if [[ "$manager" == "pacman" ]]; then
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            paru -S --needed --noconfirm "$pkg"
        fi
    done
}

pac_packages=(
    nano kio-admin git htop flatpak wget curl ark gparted keepassxc
    chromium filezilla mpv ffmpeg code discover ntfs-3g exfatprogs
)

aur_packages=(
    onlyoffice-bin sublime-text
)

install pacman "${pac_packages[@]}"
install paru "${aur_packages[@]}"


echo "# Autostart monitoring"
printf '#!/bin/bash
firefox "http://192.168.0.64:8888/" "http://192.168.0.64:3001"
' > ~/start-browser-link.sh
sudo chmod +x ~/start-browser-link.sh

echo -e "\e[32m # Autostart \e[0m"
# GUI: KDE > System > System settings > (System) Autostart > Add New > Login Script > ~/start-browser-link.sh 
printf '[Desktop Entry]
Exec=/home/kaan/start-browser-link.sh
Icon=application-x-shellscript
Name=firefox-start-browser-link.sh
Type=Application
X-KDE-AutostartScript=true
' > /home/kaan/.config/autostart/start-browser-link.sh.desktop

# Menu > System > System Settings > Login Screen > Automatically log in: ✅ as user: kaan
echo -e "\e[32m# Autologin kde plasma\e[0m"
printf '[Autologin]
Session=plasma.desktop
User=kaan
' > /etc/plasmalogin.conf
#

