#!/bin/bash

# Omarchy Setup Master Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

# Trap errors
trap 'handle_error $LINENO' ERR

# Header
clear
echo -e "${BLUE}"
echo "   ___                            _           "
echo "  / _ \ _ __ ___   __ _ _ __ ___| |__  _   _ "
echo " | | | | '_ \` _ \ / _\` | '__/ __| '_ \| | | |"
echo " | |_| | | | | | | (_| | | | (__| | | | |_| |"
echo "  \___/|_| |_| |_|\__,_|_|  \___|_| |_|\__, |"
echo "                                       |___/ "
echo -e "${NC}"
log_info "Starting Omarchy Setup..."

# Pre-flight checks
check_not_root

# Ask for sudo upfront
log_info "Requesting sudo privileges..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Profile Selection
log_info "Detecting profile..."
PROFILE="PC"
if grep -q "Laptop" /sys/class/dmi/id/chassis_type 2>/dev/null; then
    PROFILE="Laptop"
fi

echo -e "Detected Profile: ${YELLOW}$PROFILE${NC}"
if confirm "Is this correct?"; then
    log_info "Using profile: $PROFILE"
else
    echo "Select profile:"
    select p in "Laptop" "PC" "Docked"; do
        PROFILE=$p
        break
    done
fi
export OMARCHY_PROFILE="$PROFILE"

# Main Execution Loop
STEPS=(
    "scripts/packages.sh"
    "scripts/webapps.sh"
    "scripts/themes.sh"
    "scripts/dotfiles.sh"
    "scripts/hyprland.sh"
    "scripts/apps.sh"
    "scripts/limine.sh"
)

for step in "${STEPS[@]}"; do
    SCRIPT_PATH="$SCRIPT_DIR/$step"
    if [ -f "$SCRIPT_PATH" ]; then
        log_info "Running $step..."
        bash "$SCRIPT_PATH"
        if [ $? -eq 0 ]; then
            log_success "$step completed."
        else
            log_error "$step failed."
            if ! confirm "Continue anyway?"; then
                exit 1
            fi
        fi
    else
        log_warning "Script $step not found, skipping."
    fi
done

log_success "Omarchy Setup Completed Successfully!"
log_info "Please reboot your system to ensure all changes take effect."
