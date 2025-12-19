#!/bin/bash
# High-level orchestrator: unlock → create temp user → teardown → lock
set -euo pipefail

# --- Ensure we run relative to this script's directory ---
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR"

cleanup() {
  echo "[!] Cleanup triggered."
  ./30-teardown-user.sh 2>/dev/null || true
  ./40-lock.sh 2>/dev/null || true
}
trap cleanup EXIT

clear
echo "=== VeraCrypt → Temporary User Workflow ==="

if ./10-unlock.sh; then
  if ./20-create-user.sh; then
    ./30-teardown-user.sh
  fi
fi

./40-lock.sh
trap - EXIT
echo "=== All done ==="