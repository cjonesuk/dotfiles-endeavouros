#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "CONFIGURING GIT"
echo

echo "Please enter name"
read name

echo "Please enter email"
read email

git config --global user.name $name
git config --global user.email $email
git config --global init.defaultBranch main

echo "Github Auth Login"

gh auth login

echo
echo "Done!"
echo
