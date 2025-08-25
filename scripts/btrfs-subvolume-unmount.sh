#!/bin/bash
# Lazily unmount one or more mount points without failing if not mounted

# Exit immediately if no arguments are given
if [ $# -eq 0 ]; then
    echo "Usage: $0 <mountpoint1> [mountpoint2 ...]"
    exit 1
fi

for MOUNT_POINT in "$@"; do
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Lazy unmounting: $MOUNT_POINT"
        sudo umount -l "$MOUNT_POINT"
        if [ $? -eq 0 ]; then
            echo "Successfully unmounted $MOUNT_POINT"
        else
            echo "Failed to unmount $MOUNT_POINT"
        fi
    else
        echo "Not mounted: $MOUNT_POINT (skipping)"
    fi
done
