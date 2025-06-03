#!/bin/bash

echo "Creating target directory"
sudo mkdir -p /mnt/btrfs-data

echo "Mounting @data subvolume"
sudo mount -o subvol=@data /dev/mapper/luks-0c2fecb7-325c-4ebf-abb4-9d1a2198979b /mnt/btrfs-data

echo "Done"
