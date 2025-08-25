#!/bin/bash

sudo mkdir -p /mnt/btrfs-root
sudo mount -t btrfs /dev/mapper/luks-0c2fecb7-325c-4ebf-abb4-9d1a2198979b /mnt/btrfs-root

echo "Mounted /mnt/btrfs-root"