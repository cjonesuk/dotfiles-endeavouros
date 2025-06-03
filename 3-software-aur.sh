#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "INSTALLING AUR SOFTWARE"
echo


PKGS=(

    # SYSTEM

    'btrfs-assistant'
    'snapper-support'

    # TERMINALS

    'alacritty'

    # UTILITIES

    'appimagelauncher'              # AppImage integration
    'android-tools'
    'neovim'
    'perl-image-exiftool'
    'stow'

    # APPS ----------------------------------------------------------------

    'discord'                       # Chat for gamers
    'obsidian'                      # Markdown knowledgebase
    'obs-studio'                    # Streaming
    'gimp'                          # Image editor


)

# Change default shell
chsh -s $(which zsh)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

echo
echo "Done!"
echo
