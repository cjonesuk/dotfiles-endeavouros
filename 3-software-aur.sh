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

    # SYSTEM --------------------------------------------------------------
    'btrfs-assistant'
    'snapper-support'
    'appimagelauncher'              # AppImage integration
    'jre-openjdk'

    # TERMINALS -----------------------------------------------------------
    'alacritty'

    # TOOLS AND UTILITIES -------------------------------------------------
    'android-tools'
    'neovim'
    'perl-image-exiftool'
    'stow'

    # APPS ----------------------------------------------------------------
    'discord'                       # Chat for gamers
    'gimp'                          # Image editor
    'obsidian'                      # Markdown knowledgebase
    'obs-studio-git'                # Streaming
    'visual-studio-code-bin'        # Non-free visual studio code

)

# Change default shell
chsh -s $(which zsh)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

echo
echo "Done!"
echo
