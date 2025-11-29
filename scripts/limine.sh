#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Run omarchy-refresh-limine FIRST to ensure we have a fresh base config
if command -v omarchy-refresh-limine &> /dev/null; then
    log_info "Running omarchy-refresh-limine to sync base config..."
    omarchy-refresh-limine
else
    log_warning "omarchy-refresh-limine not found. Skipping base config sync."
fi

log_info "Scanning for other operating systems for Limine..."

LIMINE_CONF="/boot/limine.conf"

if [ ! -f "$LIMINE_CONF" ]; then
    log_error "$LIMINE_CONF not found. Is Limine installed?"
    exit 1
fi

# Disable timeout to wait forever
log_info "Disabling Limine timeout (wait forever)..."
if grep -q "^timeout:" "$LIMINE_CONF"; then
    sudo sed -i 's/^timeout:.*/timeout: no/' "$LIMINE_CONF"
else
    # Insert at the top of the file
    sudo sed -i '1i timeout: no' "$LIMINE_CONF"
fi

# Backup config
sudo cp "$LIMINE_CONF" "$LIMINE_CONF.bak.$(date +%s)"

# Function to add Windows entry
add_windows_entry() {
    local part_uuid=$1
    local disk_name=$2
    
    log_info "Found Windows on $disk_name (PARTUUID: $part_uuid)"
    
    # Check if entry already exists to avoid duplicates (simple check)
    if grep -q "$part_uuid" "$LIMINE_CONF"; then
        log_info "Entry for $part_uuid already exists."
        return
    fi

    echo "Adding Windows entry..."
    sudo tee -a "$LIMINE_CONF" <<EOF

/Windows ($disk_name)
    protocol: efi_chainload
    image_path: uuid($part_uuid):/EFI/Microsoft/Boot/bootmgfw.efi

/Windows Fallback ($disk_name)
    protocol: efi_chainload
    image_path: uuid($part_uuid):/EFI/Boot/bootx64.efi
EOF
}

# Scan for EFI partitions
# We use lsblk to find partitions with vfat type, then check contents
log_info "Scanning disks..."

# Get list of partitions: NAME, UUID, PARTUUID, FSTYPE
while read -r line; do
    uuid=$(echo "$line" | awk '{print $1}')
    partuuid=$(echo "$line" | awk '{print $2}')
    fstype=$(echo "$line" | awk '{print $3}')
    name=$(echo "$line" | awk '{print $4}')
    
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
            # Use PARTUUID if available, otherwise UUID
            id_to_use="$partuuid"
            if [ -z "$id_to_use" ]; then
                id_to_use="$uuid"
            fi
            add_windows_entry "$id_to_use" "$name"
        fi
        
        if [ "$temp_mount" = true ]; then
            sudo umount "$mountpoint"
            sudo rm -rf "$mountpoint"
        fi
    fi
done < <(lsblk -no UUID,PARTUUID,FSTYPE,NAME)

# Run limine update if needed (omarchy-refresh-limine does it)
# sudo limine-update # Uncomment if needed, but usually editing conf is enough for Limine runtime if it reads from disk
# But omarchy might have a specific update hook.


log_success "Limine configuration updated."
