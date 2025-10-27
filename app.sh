#!/bin/bash
#
# // Copyright (C) 2025

sudo apt install partitionmanager

# google-chrome
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome*.deb
# sudo apt-get install -f

# Breave
sudo apt update
sudo apt install snapd
sudo snap install snapd
sudo snap install brave

#vscode
sudo apt update
sudo apt upgrade
sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https curl -y
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg >/dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install code
sudo apt install code-insiders


