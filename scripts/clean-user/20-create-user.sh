#!/bin/bash
# 20-create-user.sh – create temporary user inside mounted ext4 device

set -euo pipefail

MAP_DEVICE=$(cat .current_device)
[[ -b "$MAP_DEVICE" ]] || { echo "Error: mapped device not found."; exit 1; }

# ------------------------------------------------------------
# 1. Ask for username
read -rp "Enter username to create [default: test]: " USERNAME
USERNAME=${USERNAME:-test}

if id "$USERNAME" &>/dev/null; then
  echo "Error: user '$USERNAME' already exists." >&2
  exit 1
fi

# ------------------------------------------------------------
# 2. Define mount & home paths
BASE_MNT="/mnt/device_mount"
HOME_DIR="${BASE_MNT}/${USERNAME}"

mkdir -p "$BASE_MNT"

# Prevent double mount
if mountpoint -q "$BASE_MNT"; then
  echo "Error: $BASE_MNT already mounted." >&2
  exit 1
fi

# ------------------------------------------------------------
# 3. Mount device safely
echo "Mounting $MAP_DEVICE at $BASE_MNT..."
mount -t ext4 -o nosuid,nodev "$MAP_DEVICE" "$BASE_MNT"

# Create user home directory
mkdir -p "$HOME_DIR"

chown root:root "$BASE_MNT"
chmod 755 "$BASE_MNT"

# ------------------------------------------------------------
# 4. Create user
useradd -M -d "$HOME_DIR" "$USERNAME"

DEFAULT_PW="$USERNAME"
read -rp "Enter password for $USERNAME [default: $DEFAULT_PW]: " PASSWORD
PASSWORD=${PASSWORD:-$DEFAULT_PW}

echo "${USERNAME}:${PASSWORD}" | chpasswd

# Fix ownership
chown -R "$USERNAME:$USERNAME" "$HOME_DIR"
chmod 700 "$HOME_DIR"

# ------------------------------------------------------------
# 5. Store state
echo "$USERNAME" > .current_user
echo "$BASE_MNT" > .current_mount

# Test writability
if ! sudo -u "$USERNAME" touch "$HOME_DIR/.write_test" &>/dev/null; then
  echo "Home not writable – aborting." >&2
  sync
  umount "$BASE_MNT" || true
  userdel "$USERNAME" || true
  exit 1
fi

rm -f "$HOME_DIR/.write_test"
sync

# ------------------------------------------------------------
# 6. Wait for completion
echo
echo "-------------------------------------------------------------"
echo " User   : $USERNAME"
echo " Home   : $HOME_DIR"
echo " Device : $MAP_DEVICE"
echo "-------------------------------------------------------------"
echo "Login ready – password is '${PASSWORD}'."
echo "Press Enter here when finished..."
read -r _
