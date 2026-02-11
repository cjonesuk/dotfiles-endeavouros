#!/bin/bash
# 10-unlock.sh
# Unlock a VeraCrypt-encrypted block device (no kernel crypto)

set -euo pipefail

echo "=== Step 1 – Unlock VeraCrypt Device (interactive) ==="
echo

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root (sudo)." >&2
  exit 1
fi

# Clean old state
rm -f .current_device .current_slot .current_user .current_mount

echo "Available block devices:"
echo "-------------------------------------------------------------"
lsblk -fp -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT | grep -v "loop" || echo "(none found)"
echo "-------------------------------------------------------------"
echo

read -rp "Enter encrypted block device to unlock (e.g. /dev/sdb1): " DEVICE
[[ -b "$DEVICE" ]] || { echo "Error: '$DEVICE' is not valid."; exit 1; }

read -rp "Enter slot number [1]: " SLOT
SLOT=${SLOT:-1}

# Prevent unlocking into already-used slot (suppress "No volumes mounted" noise)
if veracrypt -t -l 2>/dev/null | grep -q "^${SLOT}:"; then
  echo "Error: Slot $SLOT is already active." >&2
  exit 1
fi

echo
echo ">>> Launching VeraCrypt (you will be prompted)..."
sleep 1

veracrypt --text -m=nokernelcrypto --filesystem=none --slot="$SLOT" "$DEVICE"

# Detect mapped device
MAP_LINE=$(veracrypt -t -l | awk -v s="$SLOT" '$1 ~ "^"s":"')

if [[ -z "$MAP_LINE" ]]; then
  echo "Error: unable to detect mapped device." >&2
  exit 1
fi

MAP_DEVICE=$(awk '{print $3}' <<<"$MAP_LINE")

[[ -b "$MAP_DEVICE" ]] || {
  echo "Error: mapped device '$MAP_DEVICE' not found." >&2
  exit 1
}

echo "$MAP_DEVICE" > .current_device
echo "$SLOT" > .current_slot

echo
echo "Unlocked slot $SLOT → $MAP_DEVICE"
lsblk -fp "$MAP_DEVICE" || true
echo
echo "Step 1 complete. Continue with 20-create-user.sh."