# Omarchy Setup

Automated setup script for a fresh Omarchy Arch Linux installation.

## Features
- **Automated Package Installation**: Installs essential packages and user-selected apps.
- **Dotfiles Management**: Uses GNU Stow to manage configurations for Neovim, Tmux, Bash, Starship, etc.
- **Hyprland Overrides**: Configures Hyprland with granular overrides (monitors, bindings, etc.) without breaking Omarchy defaults.
- **Profile Support**: Automatically detects or allows selection of profiles (Laptop, PC, Docked) to apply specific monitor and workspace configurations.

## Usage

1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/omarchy-setup.git ~/Documents/omarchy-setup
    ```
2.  Run the installer:
    ```bash
    cd ~/Documents/omarchy-setup
    ./install.sh
    ```

## Structure
- `install.sh`: Master script.
- `scripts/`: Individual component scripts.
- `dotfiles/`: Configurations to be stowed.
- `hyprland_overrides/`: Granular Hyprland config files.
