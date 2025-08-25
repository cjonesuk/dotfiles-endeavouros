#!/bin/bash

SUBVOLUME_PATH="/dev/mapper/luks-0c2fecb7-325c-4ebf-abb4-9d1a2198979b"
SUBVOLUME_NAME="@archives"
MOUNT_POINT="/mnt/archives"
GROUP_NAME="devs"

# 1. Create the mount point directory if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point directory: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

# 2. Mount the Btrfs subvolume
echo "Mounting Btrfs subvolume '$SUBVOLUME_NAME' to '$MOUNT_POINT'"
sudo mount -o subvol="$SUBVOLUME_NAME" "$SUBVOLUME_PATH" "$MOUNT_POINT"

# 3. Check if mount was successful
if [ $? -eq 0 ]; then
    echo "Subvolume mounted successfully."

    # 4. Apply permissions and ownership to the *mounted subvolume root*
    echo "Setting ownership and permissions for $MOUNT_POINT"
    sudo chown root:"$GROUP_NAME" "$MOUNT_POINT"
    sudo chmod 2770 "$MOUNT_POINT"

    # Verify
    ls -ld "$MOUNT_POINT"

    echo "Done"
else
    echo "Error mounting subvolume!"
    exit 1
fi
