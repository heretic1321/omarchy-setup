#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_info "Updating system and installing base packages..."

# Update system
sudo pacman -Syu --noconfirm

# Install essentials
PACKAGES=(
    "stow"
    "git"
    "base-devel"
    "ghostty"
    "neovim"
    "starship"
    "tmux"
    "fastfetch"
    "btop"
)

log_info "Installing packages: ${PACKAGES[*]}"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# Set Bash as default shell
if [ "$SHELL" != "/bin/bash" ]; then
    log_info "Changing default shell to bash..."
    sudo chsh -s /bin/bash "$USER"
fi

# Remove unwanted packages (Placeholder)
UNWANTED_PACKAGES=(
    "spotify"
    "typora"    
)

for pkg in "${UNWANTED_PACKAGES[@]}"; do
    if package_is_installed "$pkg"; then
        log_info "Removing $pkg..."
        sudo pacman -Rns --noconfirm "$pkg"
    else
        log_info "$pkg is not installed, skipping removal."
    fi
done
