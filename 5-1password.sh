#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "INSTALLING 1PASSWORD"
echo

cd "${HOME}"

curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import

git clone https://aur.archlinux.org/1password.git

cd 1password
makepkg -si

echo
echo "Done!"
echo
