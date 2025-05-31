#!/bin/bash

sudo mkdir -p /mnt/btrfs-data
sudo mount -o subvol=@data /dev/mapper/luks-0c2fecb7-325c-4ebf-abb4-9d1a2198979b /mnt/btrfs-data

