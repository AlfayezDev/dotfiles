#!/usr/bin/env bash
# Stow dotfiles into $HOME.
# Canonical source of truth: ./.config (stow package tree). NEVER delete it —
# real files here are the originals that $HOME symlinks point at.

set -euo pipefail
cd "$(dirname "$0")"

# --adopt: if $HOME has a real file where the package has one, adopt it
# (move it into the package) and symlink — instead of erroring.
stow --no-folding --adopt -v -t "$HOME" .
