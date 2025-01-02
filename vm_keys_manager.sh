#!/bin/bash
# vm_keys_manager.sh

KEYS_DIR=".vm_keys"

# Backup existing keys
backup_keys() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="${KEYS_DIR}_backup_${timestamp}"
    if [ -d "$KEYS_DIR" ]; then
        cp -r "$KEYS_DIR" "$backup_dir"
        echo "Backed up keys to $backup_dir"
    fi
}

# List all VM keys
list_keys() {
    echo "VM SSH Keys:"
    for vm_dir in $KEYS_DIR/*/; do
        if [ -d "$vm_dir" ]; then
            vm_name=$(basename "$vm_dir")
            echo "- $vm_name"
            ls -l "$vm_dir"
        fi
    done
}

# Rotate keys for a specific VM
rotate_keys() {
    local vm_name=$1
    local vm_dir="$KEYS_DIR/$vm_name"
    
    if [ -d "$vm_dir" ]; then
        backup_keys
        rm -f "$vm_dir/id_rsa" "$vm_dir/id_rsa.pub"
        ssh-keygen -t rsa -b 4096 -f "$vm_dir/id_rsa" -N '' -C "$vm_name"
        echo "Rotated keys for $vm_name"
    else
        echo "VM directory not found: $vm_name"
    fi
}

case "$1" in
    "backup")
        backup_keys
        ;;
    "list")
        list_keys
        ;;
    "rotate")
        if [ -z "$2" ]; then
            echo "Usage: $0 rotate <vm_name>"
            exit 1
        fi
        rotate_keys "$2"
        ;;
    *)
        echo "Usage: $0 {backup|list|rotate <vm_name>}"
        exit 1
        ;;
esac