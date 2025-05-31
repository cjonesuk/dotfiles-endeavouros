#!/bin/bash

sudo btrfs subvolume create /mnt/btrfs-root/@data


#sudo chgrp -R datasharers /mnt/btrfs-root/@data
#sudo chmod -R g+rw /mnt/btrfs-root/@data  # For files and directories
#sudo find /mnt/btrfs-root/@data -type d -exec chmod g+s {} \; # Set SetGID on existing subdirs
