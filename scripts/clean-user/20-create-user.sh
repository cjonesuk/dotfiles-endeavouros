#!/bin/bash
# 20-create-user.sh – create temporary user inside mounted ext4 device
# Defaults: username=test, password=$USERNAME
set -euo pipefail

MAP_DEVICE=$(cat .current_device)
[[ -b "$MAP_DEVICE" ]] || { echo "Error: mapped device not found."; exit 1; }

# ------------------------------------------------------------
# 1. Ask for username (default = test)
read -rp "Enter username to create [default: test]: " USERNAME
USERNAME=${USERNAME:-test}

# If username exists already, abort
if id "$USERNAME" &>/dev/null; then
  echo "Error: user '$USERNAME' already exists." >&2
  exit 1
fi

# 2. Define base mount & home paths
BASE_MNT="/mnt/device_mount"
HOME_DIR="${BASE_MNT}/${USERNAME}"
mkdir -p "$BASE_MNT"

# ------------------------------------------------------------
# 3. Mount the unlocked device
mount -t ext4 "$MAP_DEVICE" "$BASE_MNT"

# Create user home dir under mounted device
mkdir -p "$HOME_DIR"
chown root:root "$BASE_MNT"
chmod 755 "$BASE_MNT"

# ------------------------------------------------------------
# 4. Create the user account
useradd -M -d "$HOME_DIR" "$USERNAME"

# Default password = username
DEFAULT_PW="$USERNAME"
read -rp "Enter password for $USERNAME [default: $DEFAULT_PW]: " PASSWORD
PASSWORD=${PASSWORD:-$DEFAULT_PW}

# Set password non‐interactively
echo "${USERNAME}:${PASSWORD}" | chpasswd

# Fix ownership / permissions
chown -R "$USERNAME:$USERNAME" "$HOME_DIR"
chmod 700 "$HOME_DIR"

# ------------------------------------------------------------
# 5. Store runtime info for teardown scripts
echo "$USERNAME" > .current_user
echo "$BASE_MNT" > .current_mount

# Test writability
if ! sudo -u "$USERNAME" touch "$HOME_DIR/.write_test" &>/dev/null; then
  echo "Home not writable – aborting." >&2
  umount "$BASE_MNT" || true
  userdel "$USERNAME" || true
  exit 1
fi
rm -f "$HOME_DIR/.write_test"

# ------------------------------------------------------------
# 6. Wait for user to finish
echo
echo "-------------------------------------------------------------"
echo " User : $USERNAME"
echo " Home : $HOME_DIR"
echo " Device : $MAP_DEVICE"
echo "-------------------------------------------------------------"
echo "Login ready – user password is '${PASSWORD}'."
echo "Press Enter in this terminal when finished to teardown..."
read -r _