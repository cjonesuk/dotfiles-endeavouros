#!/bin/bash
# 30-teardown-user.sh – safely terminate temp user and unmount filesystem

set -euo pipefail

USERNAME=$(cat .current_user)
BASE_MNT=$(cat .current_mount)

echo "Tearing down user '$USERNAME'..."
echo

# ---------------------------------
# 1. Terminate systemd login session
# ---------------------------------
if id "$USERNAME" &>/dev/null; then
  echo "Terminating login session..."
  loginctl terminate-user "$USERNAME" 2>/dev/null || true
  sleep 3
fi

# ---------------------------------
# 2. Kill remaining processes
# ---------------------------------
if pgrep -u "$USERNAME" >/dev/null 2>&1; then
  echo "Stopping remaining user processes..."
  pkill -u "$USERNAME" 2>/dev/null || true
  sleep 2
fi

if pgrep -u "$USERNAME" >/dev/null 2>&1; then
  echo "Force killing remaining processes..."
  pkill -9 -u "$USERNAME" 2>/dev/null || true
  sleep 1
fi

if pgrep -u "$USERNAME" >/dev/null 2>&1; then
  echo "Warning: some processes still exist for $USERNAME"
else
  echo "All user processes terminated."
fi

# ---------------------------------
# 3. Clean unmount (NO lazy unmount)
# ---------------------------------
if mountpoint -q "$BASE_MNT"; then
  echo "Flushing filesystem buffers..."
  sync

  echo "Unmounting $BASE_MNT..."
  if ! umount "$BASE_MNT"; then
    echo "Mount busy. Cleaning blocking processes..."
    fuser -km "$BASE_MNT" 2>/dev/null || true
    sleep 2
    umount "$BASE_MNT"
  fi

  echo "Final sync..."
  sync
  sleep 2

  echo "Unmount successful."
else
  echo "Mount point already unmounted."
fi

# ---------------------------------
# 4. Remove user account (data stays on device)
# ---------------------------------
if id "$USERNAME" &>/dev/null; then
  echo "Removing user account..."
  userdel "$USERNAME"
else
  echo "User already removed."
fi

# ---------------------------------
# 5. Remove mount directory
# ---------------------------------
if [[ -d "$BASE_MNT" ]] && ! mountpoint -q "$BASE_MNT"; then
  echo "Removing mount directory $BASE_MNT..."
  rmdir "$BASE_MNT" 2>/dev/null || rm -rf "$BASE_MNT"
fi

echo
echo "Teardown complete: user removed and filesystem cleanly unmounted."
