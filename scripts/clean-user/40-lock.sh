#!/bin/bash
# 40-lock.sh – safely dismount VeraCrypt volume

set -euo pipefail

echo "Locking VeraCrypt volume..."
echo

SLOT_FILE=".current_slot"

# ---------------------------------
# 1. Dismount VeraCrypt slot
# ---------------------------------
if [[ -f "$SLOT_FILE" ]]; then
  SLOT=$(cat "$SLOT_FILE")

  if veracrypt -t -l | grep -q "^${SLOT}:"; then
    echo "Dismounting VeraCrypt slot $SLOT..."
    veracrypt --text --dismount --slot="$SLOT"
  else
    echo "Slot $SLOT not active."
  fi
else
  echo "No slot file found."
fi

echo
echo "Post-cleanup VeraCrypt listing:"
veracrypt -t -l || echo "(none)"
echo "-------------------------------------------------------------"

# ---------------------------------
# 2. Remove state files
# ---------------------------------
rm -f .current_user .current_mount .current_slot .current_device

echo
echo "VeraCrypt lock step complete."
