#!/usr/bin/env bash

#

# macOS Tahoe 26.x – Intel x86_64 setup

#

# Gebruik:

# curl -fsSL https://raw.githubusercontent.com/celik23/bash/main/intel.sh | bash

#

set +e

# --------------------------------------------------

# Config

# --------------------------------------------------

BREW_PACKAGES=(git htop wget rsync tree nano fastfetch)

CASK_PACKAGES=(
visual-studio-code
google-chrome
brave-browser
firefox
onlyoffice
sublime-text
keepassxc
vlc
dropbox
)

INSTALLED=()
ALREADY_INSTALLED=()
FAILED=()

# --------------------------------------------------

# Kleuren / functies

# --------------------------------------------------

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

msg()     { echo -e "\n${GREEN}### $*${NC}"; }
info()    { echo -e "${BLUE}➜ $*${NC}"; }
success() { echo -e "${GREEN}✓ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $*${NC}"; }
error()   { echo -e "${RED}✗ $*${NC}"; }

# --------------------------------------------------

# Controle systeem

# --------------------------------------------------

[[ "$EUID" -ne 0 ]] || {
error "Dit script mag niet als root worden uitgevoerd."
exit 1
}

[[ "$(uname)" == "Darwin" ]] || {
error "Dit script is alleen voor macOS."
exit 1
}

ARCH="$(uname -m)"

[[ "$ARCH" == "x86_64" ]] || {
error "Dit script is alleen voor Intel x86_64 Macs."
error "Gevonden: $ARCH"
exit 1
}

# --------------------------------------------------

# Systeem informatie

# --------------------------------------------------

msg "macOS installatie"

echo "Gebruiker:    $USER"
echo "Architectuur: $ARCH"
echo
sw_vers

echo
system_profiler SPHardwareDataType |
grep -E "Model Name|Processor Name|Processor Speed|Memory" || true

# --------------------------------------------------

# Sudo

# --------------------------------------------------

msg "Checking sudo..."

sudo -v || exit 1

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

```
warn "Wacht totdat de installatie klaar is."
read -rp "Druk ENTER wanneer klaar..."

xcode-select -p >/dev/null 2>&1 ||
    { error "Xcode Command Line Tools installatie mislukt."; exit 1; }

success "Xcode Command Line Tools installed."
```

else
info "Xcode Command Line Tools already installed."
fi

# --------------------------------------------------

# Homebrew

# --------------------------------------------------

msg "Checking Homebrew..."

export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

if ! command -v brew >/dev/null 2>&1; then
info "Installing Homebrew..."

```
/bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

fi

command -v brew >/dev/null 2>&1 ||
{ error "Homebrew installatie mislukt."; exit 1; }

BREW_PREFIX="$(brew --prefix)"

info "Homebrew: $(command -v brew)"
info "Prefix: $BREW_PREFIX"

[[ "$BREW_PREFIX" == "/usr/local" ]] &&
success "Intel Homebrew detected." ||
warn "Unexpected Homebrew prefix: $BREW_PREFIX"

# --------------------------------------------------

# Update Homebrew

# --------------------------------------------------

msg "Updating Homebrew..."
brew update && success "Homebrew updated." ||
warn "Homebrew update failed. Continuing..."

# --------------------------------------------------

# Package installatie functie

# --------------------------------------------------

install_packages() {
local type="$1"
shift

```
for pkg in "$@"; do

    if brew list "$type" "$pkg" >/dev/null 2>&1; then
        info "$pkg already installed."
        ALREADY_INSTALLED+=("$pkg")

    elif brew install "$type" "$pkg"; then
        success "$pkg installed."
        INSTALLED+=("$pkg")

    else
        error "$pkg installation failed."
        FAILED+=("$pkg")
    fi

done
```

}

# --------------------------------------------------

# Terminal packages

# --------------------------------------------------

msg "Installing command line packages..."
install_packages --formula "${BREW_PACKAGES[@]}"

# --------------------------------------------------

# GUI applications

# --------------------------------------------------

msg "Installing applications..."
install_packages --cask "${CASK_PACKAGES[@]}"

# --------------------------------------------------

# macOS instellingen

# --------------------------------------------------

msg "Finder settings..."
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
killall Finder 2>/dev/null || true

msg "Screenshot settings..."
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots"
killall SystemUIServer 2>/dev/null || true

msg "Dock settings..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
killall Dock 2>/dev/null || true

msg "24 hour clock..."
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# --------------------------------------------------

# SSH / Git

# --------------------------------------------------

msg "SSH directory..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

msg "Git configuration..."
git config --global init.defaultBranch main
git config --global pull.rebase false

# --------------------------------------------------

# Cleanup

# --------------------------------------------------

msg "Homebrew cleanup..."
brew cleanup || warn "Cleanup failed."

# --------------------------------------------------

# Resultaat

# --------------------------------------------------

msg "Installation complete"

echo "============================================"
echo " macOS Setup completed"
echo "============================================"
echo
echo "User:         $USER"
echo "Architecture: $ARCH"
echo "Homebrew:     $(brew --version | head -n 1)"

echo
echo "--------------------------------------------"
echo " Newly installed"
echo "--------------------------------------------"

((${#INSTALLED[@]})) &&
printf '  ✓ %s\n' "${INSTALLED[@]}" ||
echo "  None"

echo
echo "--------------------------------------------"
echo " Already installed"
echo "--------------------------------------------"

((${#ALREADY_INSTALLED[@]})) &&
printf '  ➜ %s\n' "${ALREADY_INSTALLED[@]}" ||
echo "  None"

echo
echo "--------------------------------------------"
echo " Failed installations"
echo "--------------------------------------------"

((${#FAILED[@]})) &&
printf '  ✗ %s\n' "${FAILED[@]}" ||
echo "  None ✓"

echo
echo "============================================"

if ((${#FAILED[@]} == 0)); then
echo -e "${GREEN} DONE ✓${NC}"
else
echo -e "${YELLOW} DONE WITH ERRORS ⚠${NC}"
fi

echo "============================================"
