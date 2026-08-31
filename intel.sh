#!/usr/bin/env bash

#

# macOS Tahoe 26.x – Intel x86_64 Mac setup

#

# Installeert software via Homebrew

# Intel / x86_64 compatible

#

# Gebruik:

# curl -fsSL https://raw.githubusercontent.com/celik23/bash/main/intel.sh | bash

#

set +e

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
vlc
dropbox
)

# --------------------------------------------------

# Resultaten

# --------------------------------------------------

INSTALLED=()
ALREADY_INSTALLED=()
FAILED=()

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

success() {
echo -e "${GREEN}✓ $*${NC}"
}

# --------------------------------------------------

# Controle gebruiker

# --------------------------------------------------

if [[ "$EUID" -eq 0 ]]; then
error "Dit script mag NIET als root worden uitgevoerd."
echo
echo "Gebruik:"
echo "  bash intel.sh"
echo
echo "NIET:"
echo "  sudo bash intel.sh"
exit 1
fi

# --------------------------------------------------

# Controle macOS

# --------------------------------------------------

if [[ "$(uname)" != "Darwin" ]]; then
error "Dit script is alleen voor macOS."
exit 1
fi

# --------------------------------------------------

# Controle CPU architectuur

# --------------------------------------------------

ARCH="$(uname -m)"

if [[ "$ARCH" != "x86_64" ]]; then
error "Dit script is bedoeld voor Intel x86_64 Macs."
echo
echo "Gevonden architectuur: $ARCH"
exit 1
fi

# --------------------------------------------------

# Systeem informatie

# --------------------------------------------------

msg "macOS installatie"

echo "Gebruiker:"
echo "  $USER"

echo
echo "Architectuur:"
echo "  $ARCH"

echo
echo "macOS versie:"
sw_vers

echo
echo "Hardware:"
system_profiler SPHardwareDataType |
grep -E "Model Name|Processor Name|Processor Speed|Memory" || true

# --------------------------------------------------

# Vraag sudo één keer

# --------------------------------------------------

msg "Checking sudo..."

if ! sudo -v; then
error "Sudo authenticatie mislukt."
exit 1
fi

# Houd sudo-ticket actief tijdens installatie

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

```
info "Installing Xcode Command Line Tools..."

xcode-select --install

echo
warn "Wacht totdat de installatie klaar is."
read -rp "Druk ENTER wanneer klaar..."

if ! xcode-select -p >/dev/null 2>&1; then
    error "Xcode Command Line Tools zijn niet geïnstalleerd."
    exit 1
fi

success "Xcode Command Line Tools installed."
```

else

```
info "Xcode Command Line Tools already installed."
```

fi

# --------------------------------------------------

# Homebrew

# --------------------------------------------------

msg "Checking Homebrew..."

# Intel Homebrew locatie

INTEL_BREW="/usr/local/bin/brew"

# Voeg Intel Homebrew toe aan PATH

if [[ -x "$INTEL_BREW" ]]; then
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# Installeer Homebrew indien nodig

if ! command -v brew >/dev/null 2>&1; then

```
info "Homebrew not found."
info "Installing Intel Homebrew..."

/bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
```

fi

# --------------------------------------------------

# Definitieve Homebrew controle

# --------------------------------------------------

if ! command -v brew >/dev/null 2>&1; then

```
error "Homebrew kon niet worden gevonden."
echo
echo "Verwachte locatie:"
echo "  /usr/local/bin/brew"
exit 1
```

fi

BREW_PATH="$(command -v brew)"
BREW_PREFIX="$(brew --prefix)"

info "Homebrew found: $BREW_PATH"
info "Homebrew prefix: $BREW_PREFIX"

# Controle Intel Homebrew

if [[ "$BREW_PREFIX" != "/usr/local" ]]; then

```
warn "Homebrew prefix is niet /usr/local."
warn "Gevonden: $BREW_PREFIX"
```

else

```
success "Intel Homebrew detected."
```

fi

# --------------------------------------------------

# Update Homebrew

# --------------------------------------------------

msg "Updating Homebrew..."

if brew update; then
success "Homebrew updated."
else
warn "Homebrew update failed. Continuing..."
fi

# --------------------------------------------------

# Terminal packages

# --------------------------------------------------

msg "Installing command line packages..."

for pkg in "${BREW_PACKAGES[@]}"; do

```
if brew list --formula "$pkg" >/dev/null 2>&1; then

    info "$pkg already installed."
    ALREADY_INSTALLED+=("$pkg")

else

    info "Installing $pkg..."

    if brew install "$pkg"; then
        success "$pkg installed."
        INSTALLED+=("$pkg")
    else
        error "$pkg installation failed."
        FAILED+=("$pkg")
    fi

fi
```

done

# --------------------------------------------------

# GUI Applications

# --------------------------------------------------

msg "Installing applications..."

for pkg in "${CASK_PACKAGES[@]}"; do

```
if brew list --cask "$pkg" >/dev/null 2>&1; then

    info "$pkg already installed."
    ALREADY_INSTALLED+=("$pkg")

else

    info "Installing $pkg..."

    if brew install --cask "$pkg"; then
        success "$pkg installed."
        INSTALLED+=("$pkg")
    else
        error "$pkg installation failed."
        FAILED+=("$pkg")
    fi

fi
```

done

# --------------------------------------------------

# Finder instellingen

# --------------------------------------------------

msg "Finder settings..."

# Toon verborgen bestanden

defaults write com.apple.finder AppleShowAllFiles -bool true

# Toon bestandsextensies

defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Herstart Finder

killall Finder 2>/dev/null || true

# --------------------------------------------------

# Screenshots

# --------------------------------------------------

msg "Screenshot settings..."

mkdir -p "$HOME/Pictures/Screenshots"

defaults write com.apple.screencapture location 
"$HOME/Pictures/Screenshots"

killall SystemUIServer 2>/dev/null || true

# --------------------------------------------------

# Dock

# --------------------------------------------------

msg "Dock settings..."

# Dock automatisch verbergen

defaults write com.apple.dock autohide -bool true

# Geen vertraging bij tonen/verbergen

defaults write com.apple.dock autohide-delay -float 0

killall Dock 2>/dev/null || true

# --------------------------------------------------

# 24 uur tijd

# --------------------------------------------------

msg "Setting 24 hour clock..."

defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# --------------------------------------------------

# SSH directory

# --------------------------------------------------

msg "SSH directory..."

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# --------------------------------------------------

# Git configuratie

# --------------------------------------------------

msg "Git configuration..."

git config --global init.defaultBranch main
git config --global pull.rebase false

# --------------------------------------------------

# Homebrew cleanup

# --------------------------------------------------

msg "Homebrew cleanup..."

brew cleanup || warn "Homebrew cleanup failed."

# --------------------------------------------------

# Controle installatie

# --------------------------------------------------

msg "Installation complete!"

echo
echo "============================================"
echo " macOS Setup completed"
echo "============================================"

echo
echo "System:"
echo "  User:         $USER"
echo "  Architecture: $ARCH"

echo
echo "macOS:"
sw_vers

echo
echo "Homebrew:"
echo "  Path:   $(command -v brew)"
echo "  Prefix: $(brew --prefix)"
brew --version | head -n 1

# --------------------------------------------------

# Nieuw geïnstalleerd

# --------------------------------------------------

echo
echo "--------------------------------------------"
echo " Newly installed"
echo "--------------------------------------------"

if [[ ${#INSTALLED[@]} -eq 0 ]]; then
echo "  None"
else
printf '  ✓ %s\n' "${INSTALLED[@]}"
fi

# --------------------------------------------------

# Was al geïnstalleerd

# --------------------------------------------------

echo
echo "--------------------------------------------"
echo " Already installed"
echo "--------------------------------------------"

if [[ ${#ALREADY_INSTALLED[@]} -eq 0 ]]; then
echo "  None"
else
printf '  ➜ %s\n' "${ALREADY_INSTALLED[@]}"
fi

# --------------------------------------------------

# Mislukt

# --------------------------------------------------

echo
echo "--------------------------------------------"
echo " Failed installations"
echo "--------------------------------------------"

if [[ ${#FAILED[@]} -eq 0 ]]; then
echo "  None ✓"
else
printf '  ✗ %s\n' "${FAILED[@]}"
fi

echo
echo "============================================"

if [[ ${#FAILED[@]} -eq 0 ]]; then
echo -e "${GREEN} DONE ✓${NC}"
else
echo -e "${YELLOW} DONE WITH ERRORS ⚠${NC}"
fi

echo "============================================"
