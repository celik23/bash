#!/usr/bin/env bash
#
# macOS Tahoe 26.x – macOS setup
#
# Installeert software via Homebrew
# Apple Silicon compatible
#

set -euo pipefail

# --------------------------------------------------
# Config
# --------------------------------------------------

BREW_PACKAGES=(
    git
    htop
    wget
    rsync
    tree
    nano
    fastfetch
)

CASK_PACKAGES=(
    visual-studio-code
    google-chrome
    brave-browser
    firefox
    onlyoffice
    sublime-text
    keepassxc
    filezilla
    vlc
    mpv
    dropbox
)

# --------------------------------------------------
# Kleuren
# --------------------------------------------------

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

msg() {
    echo
    echo -e "${GREEN}### $*${NC}"
}

info() {
    echo -e "${BLUE}➜ $*${NC}"
}

warn() {
    echo -e "${YELLOW}⚠ $*${NC}"
}

error() {
    echo -e "${RED}✗ $*${NC}"
}

# --------------------------------------------------
# Controle macOS
# --------------------------------------------------

if [[ "$(uname)" != "Darwin" ]]; then
    error "Dit script is alleen voor macOS."
    exit 1
fi

msg "macOS installatie"

echo "macOS versie:"
sw_vers

echo
echo "Hardware:"
system_profiler SPHardwareDataType |
    grep -E "Model Name|Chip|Memory" || true

# --------------------------------------------------
# Vraag sudo één keer
# --------------------------------------------------

msg "Checking sudo..."

sudo -v

(
    while true; do
        sudo -n true
        sleep 50
    done
) 2>/dev/null &

SUDO_KEEPALIVE=$!

trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT

# --------------------------------------------------
# Xcode Command Line Tools
# --------------------------------------------------

msg "Checking Xcode Command Line Tools..."

if ! xcode-select -p >/dev/null 2>&1; then

    info "Installing Xcode Command Line Tools..."

    xcode-select --install

    echo
    echo "Wacht totdat de installatie klaar is."
    read -rp "Druk ENTER wanneer klaar..."

    if ! xcode-select -p >/dev/null 2>&1; then
        error "Xcode Command Line Tools zijn niet geïnstalleerd."
        exit 1
    fi

else
    info "Xcode Command Line Tools already installed."
fi

# --------------------------------------------------
# Homebrew
# --------------------------------------------------

msg "Checking Homebrew..."

if ! command -v brew >/dev/null 2>&1; then

    info "Homebrew not found. Installing..."

    /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

fi

# Apple Silicon Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Controle
if ! command -v brew >/dev/null 2>&1; then
    error "Homebrew kon niet worden gevonden."
    exit 1
fi

info "Homebrew found: $(command -v brew)"

# --------------------------------------------------
# Update Homebrew
# --------------------------------------------------

msg "Updating Homebrew..."

brew update

# --------------------------------------------------
# Terminal packages
# --------------------------------------------------

msg "Installing command line packages..."

for pkg in "${BREW_PACKAGES[@]}"; do

    if brew list --formula "$pkg" >/dev/null 2>&1; then
        info "$pkg already installed."
    else
        info "Installing $pkg..."
        brew install "$pkg"
    fi

done

# --------------------------------------------------
# GUI Applications
# --------------------------------------------------

msg "Installing applications..."

for pkg in "${CASK_PACKAGES[@]}"; do

    if brew list --cask "$pkg" >/dev/null 2>&1; then
        info "$pkg already installed."
    else
        info "Installing $pkg..."
        brew install --cask "$pkg"
    fi

done

# --------------------------------------------------
# Finder instellingen
# --------------------------------------------------

msg "Finder settings..."

# Toon verborgen bestanden
defaults write com.apple.finder AppleShowAllFiles -bool true

# Toon extensies
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Herstart Finder
killall Finder 2>/dev/null || true

# --------------------------------------------------
# Screenshots
# --------------------------------------------------

msg "Screenshot settings..."

mkdir -p "$HOME/Pictures/Screenshots"

defaults write com.apple.screencapture location \
    "$HOME/Pictures/Screenshots"

killall SystemUIServer 2>/dev/null || true

# --------------------------------------------------
# Dock
# --------------------------------------------------

msg "Dock settings..."

# Automatisch verbergen
defaults write com.apple.dock autohide -bool true

# Geen vertraging bij tonen
defaults write com.apple.dock autohide-delay -float 0

killall Dock 2>/dev/null || true

# --------------------------------------------------
# 24 uur tijd
# --------------------------------------------------

msg "Setting 24 hour clock..."

defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# --------------------------------------------------
# SSH
# --------------------------------------------------

msg "SSH directory..."

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# --------------------------------------------------
# Git basis configuratie
# --------------------------------------------------

msg "Git configuration..."

git config --global init.defaultBranch main
git config --global pull.rebase false

# --------------------------------------------------
# Cleanup
# --------------------------------------------------

msg "Homebrew cleanup..."

brew cleanup

# --------------------------------------------------
# System informatie
# --------------------------------------------------

msg "Installation complete!"

echo
echo "============================================"
echo " macOS Setup completed"
echo "============================================"
echo

echo "macOS:"
sw_vers

echo
echo "Homebrew:"
brew --version | head -n 1

echo
echo "Installed applications:"
printf '%s\n' "${CASK_PACKAGES[@]}"

echo
echo "DONE ✓"
