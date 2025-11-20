#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"
TARGET_DIR="$HOME"

if [ ! -d "$DOTFILES_DIR" ]; then
    handle_error "Dotfiles directory not found at $DOTFILES_DIR"
fi

cd "$DOTFILES_DIR" || handle_error $LINENO

# List of packages to stow
# Ensure these match the directory names in dotfiles/
PACKAGES=("nvim" "tmux" "bash" "starship")

log_info "Stowing dotfiles..."

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        log_info "Processing $pkg..."
        
        # Clean up existing files to avoid conflicts
        # This is aggressive but requested: "remove existing conf and stow with our other defaults"
        case "$pkg" in
            nvim)
                rm -rf "$TARGET_DIR/.config/nvim"
                ;;
            tmux)
                rm -f "$TARGET_DIR/.tmux.conf"
                ;;
            bash)
                rm -f "$TARGET_DIR/.bashrc"
                ;;
            starship)
                rm -f "$TARGET_DIR/.config/starship.toml"
                ;;
        esac

        # Run stow
        stow -v -t "$TARGET_DIR" "$pkg"
    else
        log_warning "Package $pkg not found in dotfiles directory, skipping."
    fi
done
