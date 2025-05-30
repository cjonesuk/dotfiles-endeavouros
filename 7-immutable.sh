#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "IMMUTABLE BOOT SETUP"
echo
 

set -euo pipefail

# Prompt for root password first
sudo -v


MODULE_DIR="/usr/lib/dracut/modules.d/95immutable"


echo "Creating immutable dracut module in $MODULE_DIR..."

sudo mkdir -p "$MODULE_DIR"

# module-setup.sh
sudo tee "$MODULE_DIR/module-setup.sh" > /dev/null <<'EOF'
#!/bin/bash

check() {
    exit 0
}

depends() {
    echo rootfs-block bash grep
    exit 0
}

install() {
    inst_hook pre-mount 90 "$moddir/immutable.sh"
}
EOF

# immutable.sh
sudo tee "$MODULE_DIR/immutable.sh" > /dev/null <<'EOF'
# Check if ' boot=immutable' exists in /proc/cmdline
# Use 'grep -q' which exits 0 on match, 1 on no match
if ! grep -q " boot=immutable" /proc/cmdline; then
    echo "[immutable] boot=immutable not found in /proc/cmdline, skipping overlay setup"
    return 0
fi

echo "[immutable] Activating tmpfs overlay for /var, /tmp, and /var/log..."

# Ensure the /overlay mount point exists
mountpoint -q /overlay || mount -t tmpfs tmpfs /overlay

for dir in var tmp var/log; do
    # Ensure directories exist within the tmpfs overlay
    mkdir -p /overlay/${dir}/upper /overlay/${dir}/work /overlay/${dir}/merged
    # Mount the overlay filesystem
    # The original /${dir} directory is the lowerdir, implicitly read-only
    mount -t overlay overlay -o lowerdir=/${dir},upperdir=/overlay/${dir}/upper,workdir=/overlay/${dir}/work /overlay/${dir}/merged
    # Bind mount the merged overlay onto the original directory
    mount --bind /overlay/${dir}/merged /${dir}
    echo "[immutable] Mounted overlay on /${dir}"
done

echo "[immutable] Overlay setup complete."
EOF

# Make scripts executable
sudo chmod +x "$MODULE_DIR/module-setup.sh" "$MODULE_DIR/immutable.sh"

echo "✅ Immutable dracut module created."



echo "📦 To apply, run:"
echo "    sudo dracut-rebuild"

echo
echo "Done!"
echo
