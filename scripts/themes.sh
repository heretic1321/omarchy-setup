#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

THEMES_SRC="$SCRIPT_DIR/../themes"
THEMES_DEST="$HOME/.config/omarchy/themes"

log_info "Running scripts/themes.sh..."

if [ ! -d "$THEMES_SRC" ]; then
    log_warning "Themes directory not found at $THEMES_SRC. Skipping."
    exit 0
fi

log_info "Installing themes to $THEMES_DEST..."

# Create destination directory if it doesn't exist
if [ ! -d "$THEMES_DEST" ]; then
    mkdir -p "$THEMES_DEST"
    log_info "Created directory $THEMES_DEST"
fi

# Copy themes
# Using rsync if available for better syncing, otherwise cp
if command -v rsync &> /dev/null; then
    rsync -av --delete "$THEMES_SRC/" "$THEMES_DEST/"
else
    cp -r "$THEMES_SRC/"* "$THEMES_DEST/"
fi

log_success "scripts/themes.sh completed."
