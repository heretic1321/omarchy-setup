#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OVERRIDES_DIR="$SCRIPT_DIR/../hyprland_overrides"
HYPR_CONFIG_DIR="$HOME/.config/hypr"
HYPR_CONFIG_FILE="$HYPR_CONFIG_DIR/hyprland.conf"

log_info "Configuring Hyprland overrides..."

# Ensure Hyprland config directory exists
if [ ! -d "$HYPR_CONFIG_DIR" ]; then
    log_warning "$HYPR_CONFIG_DIR does not exist. Creating it..."
    mkdir -p "$HYPR_CONFIG_DIR"
fi

# Link override files
# We link them to ~/.config/hypr/user_overrides/ to keep them clean, 
# or directly to ~/.config/hypr/ if we follow the existing pattern.
# Let's use a subdirectory to be cleaner as requested "organized neatly".
USER_OVERRIDES_DIR="$HYPR_CONFIG_DIR/user_overrides"
mkdir -p "$USER_OVERRIDES_DIR"

log_info "Linking override files to $USER_OVERRIDES_DIR..."
for file in "$OVERRIDES_DIR"/*.conf; do
    filename=$(basename "$file")
    target="$USER_OVERRIDES_DIR/$filename"
    if [ -L "$target" ] || [ -f "$target" ]; then
        rm -f "$target"
    fi
    ln -s "$file" "$target"
done

# Handle Profile (Monitors/Workspaces)
# We need to link the correct monitor/workspace config to a 'current' file
# that is sourced by the main config.
PROFILE=${OMARCHY_PROFILE:-PC} # Default to PC if not set
log_info "Applying profile: $PROFILE"

# Function to switch profile
apply_profile() {
    local prof=$1
    local lower_prof=$(echo "$prof" | tr '[:upper:]' '[:lower:]')
    
    # Monitors
    if [ -f "$USER_OVERRIDES_DIR/monitors.${lower_prof}.conf" ]; then
        ln -sf "$USER_OVERRIDES_DIR/monitors.${lower_prof}.conf" "$USER_OVERRIDES_DIR/monitors.current.conf"
    else
        log_warning "No monitor config found for profile $prof, defaulting to monitors.conf"
        ln -sf "$USER_OVERRIDES_DIR/monitors.conf" "$USER_OVERRIDES_DIR/monitors.current.conf"
    fi

    # Workspaces
    if [ -f "$USER_OVERRIDES_DIR/workspaces.${lower_prof}.conf" ]; then
        ln -sf "$USER_OVERRIDES_DIR/workspaces.${lower_prof}.conf" "$USER_OVERRIDES_DIR/workspaces.current.conf"
    else
        # Create empty if not exists to avoid errors
        touch "$USER_OVERRIDES_DIR/workspaces.current.conf"
    fi
}

apply_profile "$PROFILE"

# Update hyprland.conf to source our overrides
# We need to ensure these lines exist in the main config
OVERRIDES_TO_SOURCE=(
    "source = $USER_OVERRIDES_DIR/envs.conf"
    "source = $USER_OVERRIDES_DIR/input.conf"
    "source = $USER_OVERRIDES_DIR/bindings.conf"
    "source = $USER_OVERRIDES_DIR/autostart.conf"
    "source = $USER_OVERRIDES_DIR/monitors.current.conf"
    "source = $USER_OVERRIDES_DIR/workspaces.current.conf"
)

log_info "Updating $HYPR_CONFIG_FILE to source overrides..."

if [ ! -f "$HYPR_CONFIG_FILE" ]; then
    log_warning "$HYPR_CONFIG_FILE not found. Creating a basic one."
    touch "$HYPR_CONFIG_FILE"
fi

# Append sources if not present
for line in "${OVERRIDES_TO_SOURCE[@]}"; do
    if ! grep -Fxq "$line" "$HYPR_CONFIG_FILE"; then
        echo "$line" >> "$HYPR_CONFIG_FILE"
        log_success "Added: $line"
    else
        log_info "Already present: $line"
    fi
done

log_success "Hyprland configuration updated."
