
#!/bin/bash

# -S  install/sync packages
# -y  refresh package databases
# -u  upgrade all packages

echo "# 💻 CachyOS / Arch Linux "
sudo pacman -Syu --noconfirm
#sudo pacman --sync --refresh --sysupgrade --noconfirm

echo "# Browser: brave, chromium, keepassxc"
sudo pacman -S --noconfirm brave chromium 

echo "# Install discover and htop"
sudo pacman -S --noconfirm discover htop 

echo "# Tools"
sudo pacman -S --noconfirm p7zip gparted keepassxc filezilla

echo "# ffmpeg"
sudo pacman -S --noconfirm mpv ffmpeg

echo "# Only office"
sudo pacman -S --noconfirm onlyoffice-bin

echo "# Text editor VScode"
sudo pacman -S --noconfirm code 

###
echo "# Install paru"
sudo pacman -S --noconfirm paru
    
echo "# Only office with paru"
paru -S -noconfirm onlyoffice-bin

echo "# Text editor sublime text"
paru -S --noconfirm sublime-text # > q > y

echo "# Autostart monitoring"
printf '#!/bin/bash
firefox "http://192.168.0.64:8888/" "http://192.168.0.64:3001"
' > ~/start-browser-link.sh

echo "# Autostart"
sudo chmod +x ~/start-browser-link.sh
# GUI: KDE > System > System settings > Autostart > Add New > Login Script > ~/start-browser-link.sh 
printf '[Desktop Entry]
Exec=/home/kaan/start-browser-link.sh
Icon=application-x-shellscript
Name=firefox-start-browser-link.sh
Type=Application
X-KDE-AutostartScript=true
' > /home/kaan/.config/autostart/start-browser-link.sh.desktop

echo "# autologin kde plasma"
# Menu > System > System Settings > Login Screen > Automatically log in: ✅ as user: kaan

# EndeavourOS add ntfs and exfat
sudo pacman -S ntfs-3g exfatprogs

