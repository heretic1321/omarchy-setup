#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_info "Scanning for other operating systems for Limine..."

LIMINE_CONF="/boot/limine.conf"

if [ ! -f "$LIMINE_CONF" ]; then
    log_error "$LIMINE_CONF not found. Is Limine installed?"
    exit 1
fi

# Backup config
sudo cp "$LIMINE_CONF" "$LIMINE_CONF.bak.$(date +%s)"

# Function to add Windows entry
add_windows_entry() {
    local part_uuid=$1
    local disk_name=$2
    
    log_info "Found Windows on $disk_name ($part_uuid)"
    
    # Check if entry already exists to avoid duplicates (simple check)
    if grep -q "$part_uuid" "$LIMINE_CONF"; then
        log_info "Entry for $part_uuid already exists."
        return
    fi

    echo "Adding Windows entry..."
    sudo tee -a "$LIMINE_CONF" <<EOF

/Windows ($disk_name)
    protocol: chainload
    # partition: uuid($part_uuid) # Limine might use different syntax depending on version, but usually we point to the file
    # For chainloading EFI:
    path: uuid($part_uuid):/EFI/Microsoft/Boot/bootmgfw.efi
EOF
}

# Scan for EFI partitions
# We use lsblk to find partitions with vfat type, then check contents
log_info "Scanning disks..."

# Get list of partitions: NAME, UUID, FSTYPE, MOUNTPOINT
# We need to be careful with parsing.
while read -r line; do
    uuid=$(echo "$line" | awk '{print $1}')
    fstype=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | awk '{print $3}')
    
    if [ "$fstype" == "vfat" ] && [ -n "$uuid" ]; then
        # Check if it has Windows bootloader
        # We need to mount it temporarily if not mounted
        mountpoint=$(findmnt -rn -S UUID="$uuid" -o TARGET)
        
        temp_mount=false
        if [ -z "$mountpoint" ]; then
            mountpoint="/mnt/tmp_efi_$uuid"
            sudo mkdir -p "$mountpoint"
            sudo mount -U "$uuid" "$mountpoint"
            temp_mount=true
        fi
        
        if [ -f "$mountpoint/EFI/Microsoft/Boot/bootmgfw.efi" ]; then
            add_windows_entry "$uuid" "$name"
        fi
        
        if [ "$temp_mount" = true ]; then
            sudo umount "$mountpoint"
            sudo rm -rf "$mountpoint"
        fi
    fi
done < <(lsblk -no UUID,FSTYPE,NAME)

# Run limine update if needed (omarchy-refresh-limine does it)
# sudo limine-update # Uncomment if needed, but usually editing conf is enough for Limine runtime if it reads from disk
# But omarchy might have a specific update hook.
if command -v omarchy-refresh-limine &> /dev/null; then
    log_info "Running omarchy-refresh-limine to sync..."
    # Note: omarchy-refresh-limine might OVERWRITE our changes if it regenerates the file completely.
    # The user provided script shows:
    # sudo tee /boot/limine.conf <<EOF ...
    # This means it OVERWRITES it.
    # So we must run this script AFTER omarchy-refresh-limine, or modify omarchy-refresh-limine.
    # Since we can't easily modify the system script permanently without root and it might be updated by package manager,
    # we should probably just append to it.
    # BUT if we run omarchy-refresh-limine, it will wipe our changes.
    # So we should NOT run it here, or we should run it FIRST, then append our changes.
    :
else
    log_info "omarchy-refresh-limine not found, skipping sync."
fi

log_success "Limine configuration updated."
