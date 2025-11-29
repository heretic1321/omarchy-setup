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

# Install Brave Browser
log_info "Installing Brave Browser using $AUR_HELPER..."
$AUR_HELPER -S --needed --noconfirm brave-bin

# Install other apps
APPS=(
    "nordvpn-gui"
)

log_info "Installing other apps: ${APPS[*]}"
for app in "${APPS[@]}"; do
    log_info "Installing $app..."
    if ! $AUR_HELPER -S --needed --noconfirm "$app"; then
        log_warning "Failed to install $app"
    fi
done
