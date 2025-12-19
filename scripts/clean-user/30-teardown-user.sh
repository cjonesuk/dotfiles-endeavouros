#!/bin/bash
# 30-teardown-user.sh – remove temp user account and unmount device
# Keeps the user's home directory on the device but deletes the mount folder.
set -euo pipefail

USERNAME=$(cat .current_user)
BASE_MNT=$(cat .current_mount)

echo "Tearing down user '$USERNAME'..."

# --- 1. Kill all processes for that user ---
if pgrep -u "$USERNAME" >/dev/null; then
  echo "Terminating user processes..."
  pkill -u "$USERNAME" || true
  sleep 2
  if pgrep -u "$USERNAME" >/dev/null; then
    echo "Force‑killing remaining processes..."
    pkill -9 -u "$USERNAME" || true
  fi
fi

# --- 2. End lingering systemd sessions (if using logind) ---
loginctl terminate-user "$USERNAME" 2>/dev/null || true
loginctl kill-user "$USERNAME" 2>/dev/null || true

# --- 3. Unmount the mount point (retry + lazy unmount fallback) ---
echo "Unmounting $BASE_MNT..."
for attempt in {1..3}; do
  if umount "$BASE_MNT" 2>/dev/null; then
    echo "Unmounted successfully."
    break
  else
    echo "Attempt $attempt: mount is busy, waiting..."
    sleep 2
  fi
done

if mountpoint -q "$BASE_MNT"; then
  echo "Force lazy unmount..."
  umount -l "$BASE_MNT" || echo "Warning: lazy unmount failed."
fi

# --- 4. Delete the system account only (keep data on device) ---
if id "$USERNAME" &>/dev/null; then
  echo "Removing user account (data preserved on device)..."
  userdel "$USERNAME" || echo "Warning: could not delete user '$USERNAME'."
else
  echo "User '$USERNAME' already removed or missing."
fi

# --- 5. Delete the mount directory after unmount ---
if [[ -d "$BASE_MNT" && ! $(mountpoint -q "$BASE_MNT"; echo $?) ]]; then
  # mountpoint -q returns 0 if still mounted; we only remove if unmounted
  echo "Removing mount point directory $BASE_MNT..."
  rmdir "$BASE_MNT" 2>/dev/null || rm -rf "$BASE_MNT"
fi

# --- 6. Clean up workflow state files ---
rm -f ".current_user" ".current_mount"
echo
echo "Teardown complete: user account removed, device unmounted, and mount point deleted."