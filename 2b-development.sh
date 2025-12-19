#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "INSTALLING DEVELOPMENT TOOLS"
echo

PKGS=(

    # MISC DEVELOPMENT ---------------------------------------------------------

    'tree-sitter-cli'         # CLI for treesitter
    'neovim'                  # Neovim
    'lazygit'                 # Lazygit
    'github-cli'              # GitHub CLI
    'docker'                # Docker engine
    'docker-compose'        # Docker compose cli tool
    'electron'              # Cross-platform development using Javascript
    'git'                   # Version control system
    'meld'                  # File/directory comparison
    'nodejs'                # Javascript runtime environment
    'npm'                   # Node package manager
    'python'                # Scripting language
    'yarn'                  # Dependency management (Hyper needs this)
    'opam'                  # Ocaml package manager

    # C / C++

    'gcc'                   # C/C++ compiler
    'glibc'                 # C libraries
    'clang'                 # C compiler
    'clangd'                # C language server
    'cmake'                 # Cross-platform open-source make system

    # Lua

    'lua'                   # Lua programming language
    'luarocks'              # Lua package manager
    'lua-language-server'   # Lua
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo
echo "Done!"
echo
