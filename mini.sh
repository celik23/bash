#!/usr/bin/env bash
#
# macOS Tahoe 26.x – Mac mini M4 setup
#
# Installeert software via Homebrew
# Apple Silicon compatible
#

set +e

# --------------------------------------------------
# Config
# --------------------------------------------------
BREW_PACKAGES=(
    git htop wget curl rsync tree nano fastfetch
)

CASK_PACKAGES=(
    visual-studio-code google-chrome brave-browser firefox onlyoffice
    sublime-text keepassxc filezilla vlc mpv dropbox
)

# --------------------------------------------------
# Kleuren
# --------------------------------------------------
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
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

# --------------------------------------------------
# Controle macOS
# --------------------------------------------------
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Dit script is alleen voor macOS."
    exit 1
fi

msg "macOS installatie"

echo "macOS versie:"
sw_vers

echo
echo "Hardware:"
system_profiler SPHardwareDataType | grep -E "Model Name|Chip|Memory"

# --------------------------------------------------
# Vraag sudo één keer
# --------------------------------------------------
sudo -v || exit 1

(
    while true; do
        sudo -n true
        sleep 50
    done
) 2>/dev/null &

SUDO_KEEPALIVE=$!

trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null' EXIT

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
else
    info "Xcode Command Line Tools already installed."
fi

# --------------------------------------------------
# Homebrew
# --------------------------------------------------
msg "Checking Homebrew..."

if ! command -v brew >/dev/null 2>&1; then

    info "Installing Homebrew..."

    /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    info "Homebrew already installed."
fi

# Zorg dat brew beschikbaar is
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --------------------------------------------------
# Update Homebrew
# --------------------------------------------------
msg "Updating Homebrew..."
# brew update
# brew upgrade

# --------------------------------------------------
# Terminal packages
# --------------------------------------------------

msg "Installing command line packages..."

for pkg in "${BREW_PACKAGES[@]}"; do
    info "Installing $pkg..."
    brew install "$pkg"
done

# --------------------------------------------------
# GUI Applications
# --------------------------------------------------
msg "Installing applications..."

for pkg in "${CASK_PACKAGES[@]}"; do
    info "Installing $pkg..."
    brew install --cask "$pkg"
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

# Sneller tonen/verbergen
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
