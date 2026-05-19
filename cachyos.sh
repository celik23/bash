
#!/bin/bash
#
#💻 cachyos: 
# -S	install/sync packages
# -y	refresh package databases
# -u	upgrade alle packages
sudo pacman -Syu

echo "# Browser: brave, chromium keepassxc"
sudo pacman -S -noconfirm brave chromium keepassxc # firefox
sudo pacman -S -noconfirm discover htop p7zip gparted filezilla 
sudo pacman -S -noconfirm nautilus # dolphin krusader thunar pcmanfm
sudo pacman -S -noconfirm mpv ffmpeg
sudo pacman -S -noconfirm onlyoffice-bin

# sudo pacman -S libreoffice-fresh     # install
# sudo pacman -R libreoffice-fresh     # revome

echo "# onlyoffice"
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
