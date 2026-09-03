# Dotfiles
test
Personal dotfiles managed with GNU Stow.

## Overview

- Neovim configuration (based on kickstart.nvim)
- Zsh configuration with aliases
- Ghostty terminal settings

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Neovim](https://neovim.io/) 0.12+
- [tree-sitter CLI](https://tree-sitter.github.io/tree-sitter/) 0.26.1+
- [Ghostty](https://github.com/mitchellh/ghostty) terminal
- [Oh My Zsh](https://ohmyz.sh/)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-completions](https://github.com/zsh-users/zsh-completions)

## Installation

```bash
# Clone repository
git clone https://github.com/alfayez-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install with stow (creates symlinks)
./setup.sh
```

## Structure

```
~/dotfiles/
├── .config/              # XDG Base Directory configs
│   ├── ghostty/          # Terminal configuration
│   ├── nvim/             # Neovim configuration
│   └── zsh/              # Zsh configurations
│       ├── aliases       # Shared aliases
│       ├── arch          # Arch (btw) Linux (btw) specific settings
│       └── macos         # macOS specific settings
├── .zshrc                # Main Zsh config (machine-specific, not tracked)
├── .stow-local-ignore    # Files to exclude from stow
├── setup.sh              # Installation script (Linux + macOS)
└── README.md             # Documentation
```

## Secrets Management

Sensitive data is stored in `~/.config/secrets/secrets` (not tracked in git).

```bash
# Example ~/.config/secrets/secrets (never committed)
export OPENAI_API_KEY="your-key-here"
export ZED_SENTRY_TOKEN="..."
export ZED_KAGI_API_KEY="..."
```

## Zed sync (PC + laptop)

`setup.sh` rebuilds `~/.config/zed/settings.json` as a **real file** =
tracked template + your local tokens. Tokens live only in the gitignored
secrets file, never in the repo. Zed auto-installs every extension listed
in `auto_install_extensions` (168 today) on first launch, so both machines
converge on the same editor. Keymap and themes are stowed symlinks. Tasks are
written as a local file so macOS can use `/bin/bash` while Linux keeps the
tracked `/usr/bin/bash` path.

Rules:
- settings changes: edit `.config/zed/settings.json` (leave token fields
  empty), then `./setup.sh` on each machine
- machine-specific files (`.zshrc`, tokens): not tracked

## Key Features

- Terminal: Transparent background with blur (Ghostty)
- Vim: Gruvbox theme, LSP support, fuzzy finding, Treesitter, GitSigns
- Custom aliases for common commands
- Platform-specific configurations for macOS and Arch (btw) Linux (btw)

## License

MIT
