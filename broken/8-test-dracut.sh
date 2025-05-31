#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "TEST DRACUT"
echo
 
# This script creates a custom Dracut module to read a kernel parameter.

set -e # Exit immediately if a command exits with a non-zero status.

MODULE_NAME="99mycustommodule"
MODULE_BASE_DIR="/usr/lib/dracut/modules.d"
MODULE_DIR="${MODULE_BASE_DIR}/${MODULE_NAME}"

SETUP_SCRIPT_NAME="module-setup.sh"
HOOK_SCRIPT_NAME="parse-my-param.sh"

# --- Content for module-setup.sh ---
read -r -d '' MODULE_SETUP_SH_CONTENT << 'EOF'
#!/bin/bash

# Called by dracut
check() {
    # Always include this module.
    return 0
}

# Called by dracut
depends() {
    # List any dracut modules this module depends on.
    return 0
}

# Called by dracut
install() {
    # Install a hook script that runs during the "cmdline" stage.
    # The script will be named "parse-my-param.sh" and placed in our module dir.
    inst_hook cmdline 50 "$moddir/parse-my-param.sh"
    # The "50" is a priority within the cmdline hook stage.
}
EOF

# --- Content for parse-my-param.sh ---
read -r -d '' PARSE_MY_PARAM_SH_CONTENT << 'EOF'
#!/bin/bash

# Dracut sources /lib/dracut-lib.sh which provides getarg, getargbool, etc.

# Example 1: Reading a parameter with a value (e.g., my_custom_param=some_value)
PARAM_VALUE=$(getarg my_custom_param=)

if [ -n "$PARAM_VALUE" ]; then
    info "MyCustomModule: Found my_custom_param with value: '$PARAM_VALUE'"
    # You can now use $PARAM_VALUE for something.
    # e.g., echo "$PARAM_VALUE" > "/run/initramfs/my_custom_param_value.txt"
else
    info "MyCustomModule: my_custom_param was not found or has no value."
fi

# Example 2: Checking for a boolean flag (e.g., my_custom_flag)
# getargbool <default_if_not_found> <param_name> [param_name_alias...]
# Default: 0 for true, any other number for false if param not found.
if getargbool 0 my_custom_flag; then
    info "MyCustomModule: Found my_custom_flag (it is set)."
    # Do something because the flag is present
else
    info "MyCustomModule: my_custom_flag is NOT set."
fi

# You can also inspect the whole command line if needed:
# KERNEL_CMDLINE=$(cat /proc/cmdline)
# info "MyCustomModule: Full kernel command line: $KERNEL_CMDLINE"

# The 'info', 'warn', 'err' functions log to dmesg and the dracut log.
EOF

echo "Creating Dracut module: ${MODULE_NAME}"

# Create module directory
if [ -d "${MODULE_DIR}" ]; then
    echo "Module directory ${MODULE_DIR} already exists. Skipping creation."
else
    echo "Creating module directory: ${MODULE_DIR}"
    sudo mkdir -p "${MODULE_DIR}"
    echo "Module directory created."
fi

# Write module-setup.sh
echo "Writing ${MODULE_DIR}/${SETUP_SCRIPT_NAME}..."
echo "${MODULE_SETUP_SH_CONTENT}" | sudo tee "${MODULE_DIR}/${SETUP_SCRIPT_NAME}" > /dev/null
sudo chmod +x "${MODULE_DIR}/${SETUP_SCRIPT_NAME}"
echo "${SETUP_SCRIPT_NAME} written and made executable."

# Write parse-my-param.sh
echo "Writing ${MODULE_DIR}/${HOOK_SCRIPT_NAME}..."
echo "${PARSE_MY_PARAM_SH_CONTENT}" | sudo tee "${MODULE_DIR}/${HOOK_SCRIPT_NAME}" > /dev/null
sudo chmod +x "${MODULE_DIR}/${HOOK_SCRIPT_NAME}"
echo "${HOOK_SCRIPT_NAME} written and made executable."

echo ""
echo "SUCCESS: Dracut module '${MODULE_NAME}' files created."
echo "-----------------------------------------------------"
echo ""
echo "NEXT STEPS:"
echo "1. Add your custom parameter to GRUB:"
echo "   Edit /etc/default/grub and add your parameter (e.g., my_custom_param=your_value or my_custom_flag) to GRUB_CMDLINE_LINUX_DEFAULT."
echo "   Example: GRUB_CMDLINE_LINUX_DEFAULT=\"quiet loglevel=3 my_custom_param=hello\""
echo ""
echo "2. Update GRUB configuration:"
echo "   sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo ""
echo "3. Rebuild your initramfs:"
echo "   sudo dracut-rebuild"
echo "   (or 'sudo dracut --force --regenerate-all' or 'sudo dracut -f')"
echo ""
echo "4. Reboot your system."
echo ""
echo "5. After reboot, verify:"
echo "   - Check kernel command line: cat /proc/cmdline"
echo "   - Check dmesg for your module's output: dmesg | grep \"MyCustomModule\""
echo ""

exit 0
