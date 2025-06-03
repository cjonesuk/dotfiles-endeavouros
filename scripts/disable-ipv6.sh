#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo "Disabling IPv6 on all interfaces..."

# Get list of interfaces from sysctl
interfaces=$(sysctl -a 2>/dev/null | grep 'net.ipv6.conf\..*\.disable_ipv6' | awk -F'.' '{print $4}' | sort -u)

for iface in $interfaces; do
    echo "Disabling IPv6 on $iface..."
    sysctl -w "net.ipv6.conf.${iface}.disable_ipv6=1"
done

# Persist settings
echo "Persisting settings in /etc/sysctl.d/99-disable-ipv6.conf..."

sudo tee /etc/sysctl.d/99-disable-ipv6.conf > /dev/null <<EOF
# Disable IPv6 on all interfaces
EOF

for iface in $interfaces; do
    echo "net.ipv6.conf.${iface}.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf > /dev/null
done

# Apply changes
sudo sysctl --system

echo "IPv6 disabled on all interfaces."
