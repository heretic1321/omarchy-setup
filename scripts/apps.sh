#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_info "Installing additional applications..."

# Install AUR helper (paru or yay)
if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
    log_info "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

AUR_HELPER="yay"
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
fi

# Install Zen Browser
# Assuming zen-browser-bin is the package name in AUR, or we might need a specific install method
# Checking if zen-browser is available in AUR
log_info "Installing Zen Browser using $AUR_HELPER..."
$AUR_HELPER -S --needed --noconfirm zen-browser-bin

# Install other apps
APPS=(
    "visual-studio-code-bin"
    "spotify"
    "discord"
)

log_info "Installing other apps: ${APPS[*]}"
$AUR_HELPER -S --needed --noconfirm "${APPS[@]}"
