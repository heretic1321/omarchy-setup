#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_info "Removing bloat webapps..."

# List of webapps to remove (Case insensitive matching against Name= in .desktop file)
TARGETS=(
    "Hey"
    "Google Contacts"
    "Google Messages"
    "Google Photos"
    "X"
    "Zoom"
    "Basecamp"
)

DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/applications/icons"

if [ ! -d "$DESKTOP_DIR" ]; then
    log_warning "Desktop directory $DESKTOP_DIR not found."
    exit 0
fi

log_info "Scanning $DESKTOP_DIR for target webapps..."

# Iterate over all desktop files
for file in "$DESKTOP_DIR"/*.desktop; do
    [ -e "$file" ] || continue
    
    # Extract Name from the desktop file
    # We use grep to find the line starting with Name=
    app_name=$(grep "^Name=" "$file" | head -n 1 | cut -d= -f2-)
    
    # Check if this app is in our target list
    for target in "${TARGETS[@]}"; do
        if [[ "${app_name,,}" == "${target,,}" ]]; then
            log_info "Found target '$target' in file: $(basename "$file")"
            
            # Remove desktop file
            rm -f "$file"
            log_success "Removed $file"
            
            # Try to remove associated icon
            # The icon usually has the same basename as the desktop file
            base_name=$(basename "$file" .desktop)
            if [ -f "$ICON_DIR/$base_name.png" ]; then
                rm -f "$ICON_DIR/$base_name.png"
                log_success "Removed icon $base_name.png"
            fi
            
            break # Move to next file
        fi
    done
done

log_success "Webapp cleanup finished."
