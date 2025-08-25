#!/bin/bash

SUBVOLUME_PATH="/dev/mapper/luks-0c2fecb7-325c-4ebf-abb4-9d1a2198979b"
SUBVOLUME_NAME="@archives"
MOUNT_POINT="/mnt/archives"
GROUP_NAME="devs"

SCRIPT_DIR="$(dirname "$0")"
"$SCRIPT_DIR/btrfs-subvolume-mount.sh" "$SUBVOLUME_PATH" "$SUBVOLUME_NAME" "$MOUNT_POINT" "$GROUP_NAME"