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
GRUB_DEFAULT_FILE="/etc/default/grub"
GRUB_CMDLINE="boot=immutable"


echo "Creating immutable dracut module in $MODULE_DIR..."

sudo mkdir -p "$MODULE_DIR"

# module-setup.sh
sudo tee "$MODULE_DIR/module-setup.sh" > /dev/null <<'EOF'
#!/bin/bash

check() {
    return 0
}

depends() {
    echo rootfs-block
    return 0
}

install() {
    inst_hook pre-mount 90 "$moddir/immutable.sh"
}
EOF

# immutable.sh
sudo tee "$MODULE_DIR/immutable.sh" > /dev/null <<'EOF'
#!/bin/sh

CMDLINE=$(cat /proc/cmdline)

if ! echo "$CMDLINE" | grep -q "boot=immutable"; then
    echo "[immutable] boot=immutable not found, skipping overlay setup"
    return 0
fi

echo "[immutable] Activating tmpfs overlay for /var, /tmp, and /var/log..."

mount -t tmpfs tmpfs /overlay

for dir in var tmp var/log; do
    mkdir -p /overlay/${dir}/upper /overlay/${dir}/work /overlay/${dir}/merged
    mount -t overlay overlay -o lowerdir=/${dir},upperdir=/overlay/${dir}/upper,workdir=/overlay/${dir}/work /overlay/${dir}/merged
    mount --bind /overlay/${dir}/merged /${dir}
done
EOF

# Make scripts executable
sudo chmod +x "$MODULE_DIR/module-setup.sh" "$MODULE_DIR/immutable.sh"

echo "✅ Immutable dracut module created."


# Check if boot=immutable is already in GRUB_CMDLINE_LINUX_DEFAULT
if grep -qE '^\s*GRUB_CMDLINE_LINUX_DEFAULT=.*\bboot=immutable\b' "$GRUB_DEFAULT_FILE"; then
    echo "boot=immutable is already present in GRUB_CMDLINE_LINUX_DEFAULT. Nothing to do."
else
    echo "Adding boot=immutable to GRUB_CMDLINE_LINUX_DEFAULT..."

    # Use sed to add boot=immutable inside the quotes, preserving existing options
    sudo sed -i -E "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\")(.*)(\")|\1\2 $GRUB_CMDLINE\3|" "$GRUB_DEFAULT_FILE"

    echo "Updating GRUB config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    echo "boot=immutable added and GRUB config updated."
fi

echo "📦 To apply, run:"
echo "    sudo dracut --force --regenerate-all"

echo
echo "Done!"
echo
