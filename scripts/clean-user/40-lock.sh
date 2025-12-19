#!/bin/bash
# 40-lock.sh – safely dismount VeraCrypt volume (loop or mapper)
set -euo pipefail

echo "Locking and cleaning up VeraCrypt volume..."
echo

# Load slot number if it exists
SLOT_FILE=".current_slot"
if [[ -f "$SLOT_FILE" ]]; then
  SLOT=$(cat "$SLOT_FILE")
else
  SLOT=""
fi

# First, show current VeraCrypt mappings
echo "Current VeraCrypt slots:"
veracrypt -t -l || echo "(none)"
echo "-------------------------------------------------------------"

# --- 1. Try dismounting using slot if known ---
if [[ -n "$SLOT" ]]; then
  if veracrypt -t -l | grep -q "^${SLOT}:"; then
    echo "Dismounting slot $SLOT..."
    veracrypt --text --dismount --slot="$SLOT" || true
  else
    echo "Slot $SLOT not currently active; continuing."
  fi
fi

# --- 2. Fallback: detect mapped devices manually (loop or mapper) ---
MAP_DEVICE_FILE=".current_device"
if [[ -f "$MAP_DEVICE_FILE" ]]; then
  MAP_DEVICE=$(cat "$MAP_DEVICE_FILE")
  if [[ -b "$MAP_DEVICE" ]]; then
    echo "Checking for mapped device $MAP_DEVICE..."
    # Determine device type
    if [[ "$MAP_DEVICE" == /dev/loop* ]]; then
      echo "Loop device detected – detaching..."
      losetup -d "$MAP_DEVICE" 2>/dev/null || true
    elif [[ "$MAP_DEVICE" == /dev/mapper/veracrypt* ]]; then
      echo "Mapper device detected – dismounting..."
      veracrypt --text --dismount "$MAP_DEVICE" || true
    fi
  fi
fi

# --- 3. Show result ---
echo
echo "Post‑cleanup VeraCrypt listing:"
veracrypt -t -l || echo "(none)"
echo "-------------------------------------------------------------"

# --- 4. Remove stale state files ---
rm -f .current_device .current_slot .current_user .current_mount

echo "VeraCrypt lock step complete."