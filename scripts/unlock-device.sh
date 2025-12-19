#!/bin/bash
# Unlock a VeraCrypt-encrypted device without using kernel crypto services.
# Produces /dev/mapper/veracryptN (unmounted).

set -euo pipefail

echo "=== VeraCrypt Device Unlock Script (-m=nokernelcrypto) ==="
echo

# Require root
if [[ $EUID -ne 0 ]]; then
  echo "Error: please run this script as root (sudo)." >&2
  exit 1
fi

# --- List block devices ---
echo "Available block devices:"
echo "-------------------------------------------------------------"
lsblk -fpno MODEL,NAME,FSTYPE,SIZE,MOUNTPOINT | column -t
echo "-------------------------------------------------------------"
echo
read -rp "Enter device to unlock (e.g. /dev/sdb1): " DEVICE

# Validate
if [[ ! -b "$DEVICE" ]]; then
  echo "Error: '$DEVICE' is not a valid block device." >&2
  exit 1
fi

# Ask for necessary inputs
read -srp "Enter VeraCrypt password: " PASSWORD
echo
read -rp "Enter slot number to use [default 1]: " SLOT
SLOT=${SLOT:-1}

read -rp "Enter PIM (press Enter for default): " PIM
PIM_FLAG=()
if [[ -n "$PIM" ]]; then
  PIM_FLAG=(--pim "$PIM")
fi

read -rp "Keyfile path (press Enter to skip): " KEYFILE
KEYFILE_FLAG=()
if [[ -n "$KEYFILE" ]]; then
  KEYFILE_FLAG=(--keyfiles "$KEYFILE")
fi

echo
echo "Unlocking $DEVICE using VeraCrypt in pure user-space mode..."
veracrypt --text \
  -m=nokernelcrypto \
  --filesystem=none \
  --non-interactive \
  --slot="$SLOT" \
  --password="$PASSWORD" \
  "${PIM_FLAG[@]}" "${KEYFILE_FLAG[@]}" \
  "$DEVICE"

echo
echo "-------------------------------------------------------------"
veracrypt -l
echo "-------------------------------------------------------------"
echo "VeraCrypt volume unlocked with -m=nokernelcrypto."
echo "Resulting block device:"
echo "    /dev/mapper/veracrypt${SLOT}"
echo
echo "You can now manually mount it, for example:"
echo "    sudo mount -t ext4 /dev/mapper/veracrypt${SLOT} /mnt/data"
echo
echo "To dismount later:"
echo "    veracrypt --dismount /dev/mapper/veracrypt${SLOT}"
echo "-------------------------------------------------------------"