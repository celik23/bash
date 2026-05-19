
#!/bin/bash

# 💻 CachyOS / Arch Linux
# -S  install/sync packages
# -y  refresh package databases
# -u  upgrade all packages

sudo pacman -Syu --noconfirm

echo "# Browser: brave, chromium, keepassxc"
sudo pacman -S --noconfirm \
    brave \
    chromium 

sudo pacman -S --noconfirm \
    discover \
    htop \

echo "# Tools"
sudo pacman -S --noconfirm \
    p7zip \
    gparted \
    keepassxc\
    filezilla
    
sudo pacman -S --noconfirm \
    mpv \
    ffmpeg

# sudo pacman -S libreoffice-fresh     # install
# sudo pacman -R libreoffice-fresh     # revome

# alternative file managers:
# dolphin
# nautilus
# krusader
# thunar
# pcmanfm

echo "# Only office"
sudo pacman -S --noconfirm \
    onlyoffice-bin
paru -S -noconfirm onlyoffice-bin

echo "# Text editor"
sudo pacman -S -noconfirm code 
paru -S sublime-text # > q > y

echo "# Autostart monitoring"
printf '#!/bin/bash
firefox "http://192.168.0.64:8888/" "http://192.168.0.64:3001"
' > ~/start-browser-link.sh

sudo chmod +x ~/start-browser-link.sh
# KDE > System > System settings >Autostart > Add New > Login Script > ~/start-browser-link.sh 

echo "# autologin kde plasma"
# Menu > System > System Settings > Login Screen > Automatically log in: ✅ as user: kaan
