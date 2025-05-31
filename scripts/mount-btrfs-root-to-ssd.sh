#!/bin/bash

sudo mkdir /mnt/btrfs-root
sudo mount -t btrfs /dev/mapper/luks-a86eebde-b05d-4231-86fb-cc62e048d63e /mnt/btrfs-root

