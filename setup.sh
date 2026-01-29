#!/bin/bash
mkdir -p "$HOME/.config/secrets"

# Stow with adopt flag to overwrite existing files
chmod +x ./stow.sh
./stow.sh

# Restore ownership of the dotfiles repo
git reset --hard

echo "Dotfiles installed successfully!"
