#!/bin/bash
# 10-unlock.sh
# Unlock a VeraCrypt-encrypted block device (no kernel crypto)
# and auto-detect the created mapping.

set -euo pipefail

echo "=== Step 1 – Unlock VeraCrypt Device (interactive, no kernel crypto) ==="
echo

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root (sudo)." >&2
  exit 1
fi

echo "Available block devices:"
echo "-------------------------------------------------------------"
lsblk -fp -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT | grep -v "loop" || echo "(none found)"
echo "-------------------------------------------------------------"
echo
read -rp "Enter encrypted block device to unlock (e.g. /dev/sdb1): " DEVICE
[[ -b "$DEVICE" ]] || { echo "Error: '$DEVICE' is not valid."; exit 1; }

read -rp "Enter slot number [1]: " SLOT
SLOT=${SLOT:-1}

echo
echo ">>> Launching VeraCrypt interactively (you’ll be prompted)..."
sleep 1

if ! veracrypt --text -m=nokernelcrypto --filesystem=none --slot="$SLOT" "$DEVICE"; then
  echo "VeraCrypt reported an error unlocking '$DEVICE'." >&2
  exit 1
fi

# --- Determine the actual mapped device from veracrypt -l ---
MAP_LINE=$(veracrypt -t -l | grep "^$SLOT:" || true)

if [[ -z "$MAP_LINE" ]]; then
  echo "Error: unable to detect mapped device (slot $SLOT)." >&2
  echo "Output of 'veracrypt -l':"
  veracrypt -t -l || true
  exit 1
fi

# Example line: 1: /dev/sdb1 /dev/loop0 /media/veracrypt1
MAP_DEVICE=$(awk '{print $3}' <<<"$MAP_LINE")

if [[ ! -b "$MAP_DEVICE" ]]; then
  echo "Warning: detected mapped device '$MAP_DEVICE' not found; using fallback detection." >&2
  MAP_DEVICE=$(echo "$MAP_LINE" | awk '{print $2}')  # fallback to second column
fi

# Record info for later scripts
echo "$MAP_DEVICE" > .current_device
echo "$SLOT" > .current_slot

echo
echo "Unlocked device for slot $SLOT → $MAP_DEVICE"
echo "-------------------------------------------------------------"
lsblk -fp "$MAP_DEVICE" || true
echo "-------------------------------------------------------------"
echo "Step 1 complete. Continue with 20-create-user.sh."