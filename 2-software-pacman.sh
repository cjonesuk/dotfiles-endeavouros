#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "INSTALLING SOFTWARE"
echo

PKGS=(

    # TERMINAL UTILITIES --------------------------------------------------

    'bleachbit'               # File deletion utility
    'cmatrix'                 # The Matrix screen animation
    'cronie'                  # cron jobs
    'curl'                    # Remote content retrieval
    'file-roller'             # Archive utility
    'github-cli'              # GitHub CLI
    'grub-btrfs'              # GRUB BTRFS snapshots
    'gtop'                    # System monitoring via terminal
    'gufw'                    # Firewall manager
    'htop'                    # Process viewer
    'lazygit'                 # Lazygit
    'ntp'                     # Network Time Protocol to set time via network.
    'numlockx'                # Turns on numlock in X11
    'p7zip'                   # 7z compression program
    'rsync'                   # Remote file sync utility
    'speedtest-cli'           # Internet speed via terminal
    'unrar'                   # RAR compression program
    'unzip'                   # Zip compression program
    'veracrypt'               # Encryption program
    'yay'                     # AUR manager
    'wget'                    # Remote content retrieval
    'vim'                     # Terminal Editor
    'zenity'                  # Display graphical dialog boxes via shell scripts
    'zip'                     # Zip compression program
    'zsh'                     # Interactive shell
    'zsh-autosuggestions'     # Zsh Plugin
    'zsh-syntax-highlighting' # Zsh Plugin

    # GENERAL UTILITIES ---------------------------------------------------

    'variety'               # Wallpaper changer

    # DEVELOPMENT ---------------------------------------------------------

    'clang'                 # C Lang compiler
    'cmake'                 # Cross-platform open-source make system
    'electron'              # Cross-platform development using Javascript
    'git'                   # Version control system
    'gcc'                   # C/C++ compiler
    'glibc'                 # C libraries
    'meld'                  # File/directory comparison
    'nodejs'                # Javascript runtime environment
    'npm'                   # Node package manager
    'python'                # Scripting language
    'yarn'                  # Dependency management (Hyper needs this)

    # MEDIA ---------------------------------------------------------------

    'celluloid'                 # Video player
    'feh'                       # Image viewer
    'v4l2loopback-dkms'         # Virtual capture

    # PRODUCTIVITY --------------------------------------------------------

    'xpdf'                  # PDF viewer

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo
echo "Done!"
echo
