#!/bin/bash
# Mount a Btrfs subvolume with group permissions

if [ $# -ne 4 ]; then
    echo "Usage: $0 <SUBVOLUME_PATH> <SUBVOLUME_NAME> <MOUNT_POINT> <GROUP_NAME>"
    exit 1
fi

SUBVOLUME_PATH="$1"
SUBVOLUME_NAME="$2"
MOUNT_POINT="$3"
GROUP_NAME="$4"

# 1. Create the mount point directory if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point directory: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

# 2. Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "$MOUNT_POINT is already mounted, skipping mount."
else
    echo "Mounting subvolume $SUBVOLUME_NAME..."
    if sudo mount -o subvol="$SUBVOLUME_NAME",compress=zstd "$SUBVOLUME_PATH" "$MOUNT_POINT"; then
        echo "Mount successful."
    else
        echo "Error: failed to mount $SUBVOLUME_NAME on $MOUNT_POINT"
        exit 1
    fi
fi

# 3. Apply permissions (always, in case they reset after mount)
echo "Setting ownership and permissions..."
if sudo chown root:"$GROUP_NAME" "$MOUNT_POINT" && sudo chmod 2770 "$MOUNT_POINT"; then
    echo "Permissions applied."
else
    echo "Warning: failed to set permissions on $MOUNT_POINT"
fi

# 4. Verify final state
ls -ld "$MOUNT_POINT"