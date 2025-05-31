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
    return 0
}

depends() {
    echo rootfs-block bash
}

install() {
    # Explicitly install the grep binary and its libraries.
    # This is the correct place to ensure the 'grep' binary is included in the initramfs.
    inst_multiple grep

    # Install your hook script into the initramfs at the pre-mount hook point.
    inst_hook pre-mount 90 "$moddir/immutable.sh"
}
EOF

# immutable.sh
sudo tee "$MODULE_DIR/immutable.sh" > /dev/null <<'EOF'
#!/bin/sh

# Debugging: Indicate script start
echo "[immutable-debug] Entering 90-immutable.sh hook."
# Debugging: Show the current PATH
echo "[immutable-debug] Current PATH: $PATH"

# Diagnostic: Check if /bin/grep exists and is executable in the initramfs environment
if [ -x /bin/grep ]; then
    echo "[immutable-debug] /bin/grep found and is executable."
else
    # If /bin/grep isn't found/executable, print a warning and try finding grep via command -v
    echo "[immutable-debug] WARNING: /bin/grep NOT found or not executable!"
    if command -v grep >/dev/null; then
        echo "[immutable-debug] WARNING: 'grep' found in PATH, but /bin/grep is not executable? Path found: $(command -v grep)"
    else
        echo "[immutable-debug] WARNING: 'grep' not found anywhere in PATH either."
        echo "[immutable-debug] Checked paths: /bin (explicit), and directories in \$PATH."
    fi
fi

# Check for ' boot=immutable' in /proc/cmdline using the absolute path to grep.
# Use 'grep -q' which exits 0 on match, 1 on no match.
# This bypasses the potentially problematic 'getarg' helper and avoids PATH issues if /bin is not in PATH.
# This is approximately line 27 in this script version.
if ! /bin/grep -q " boot=immutable" /proc/cmdline; then
    echo "[immutable] boot=immutable not found in /proc/cmdline, skipping overlay setup"
    return 0 # Use return 0 here as this is just exiting the script, not signalling build outcome
fi

echo "[immutable] boot=immutable found. Activating tmpfs overlay for /var, /tmp, and /var/log..."

# Ensure the /overlay mount point exists and is a tmpfs
mountpoint -q /overlay || mount -t tmpfs tmpfs /overlay

for dir in var tmp var/log; do
    # Create necessary directories within the tmpfs overlay mount
    mkdir -p /overlay/${dir}/upper /overlay/${dir}/work /overlay/${dir}/merged
    # Mount the overlay filesystem: lowerdir is the original read-only directory,
    # upperdir and workdir are on the tmpfs.
    # Using defaults allows read/write changes to go to upperdir.
    mount -t overlay overlay -o lowerdir=/${dir},upperdir=/overlay/${dir}/upper,workdir=/overlay/${dir}/work /overlay/${dir}/merged
    # Bind mount the merged overlay onto the original directory, effectively replacing it
    mount --bind /overlay/${dir}/merged /${dir}
    echo "[immutable] Mounted overlay on /${dir} using /overlay/${dir}/merged"
done

echo "[immutable] Overlay setup complete."

# Diagnostic: Check mount points after setup
echo "[immutable-debug] Current mount points for /var, /tmp, /var/log:"
mount | grep -E " /var | /tmp | /var/log "
EOF

sudo tee /etc/dracut.conf.d/99-local.conf > /dev/null <<'EOF'
add_dracutmodules+=" immutable "
EOF

# Make scripts executable
sudo chmod +x "$MODULE_DIR/module-setup.sh" "$MODULE_DIR/immutable.sh"

echo "✅ Immutable dracut module created."



echo "📦 To apply, run:"
echo "    sudo dracut-rebuild"

echo
echo "Done!"
echo
