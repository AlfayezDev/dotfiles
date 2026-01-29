# Dotfiles

Personal dotfiles managed with GNU Stow.

## Overview

- Neovim configuration (based on kickstart.nvim)
- Zsh configuration with aliases
- Ghostty terminal settings

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Neovim](https://neovim.io/)
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
./install.sh
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
├── .zshrc                # Main Zsh configuration
├── .stow-local-ignore    # Files to exclude from stow
├── install.sh            # Installation script
└── README.md             # Documentation
```

## Secrets Management

Sensitive data is stored in `~/.config/secrets/secrets` (not tracked in git).

```bash
# Example ~/.config/secrets/secrets
export OPENAI_API_KEY="your-key-here"
```

## Key Features

- Terminal: Transparent background with blur (Ghostty)
- Vim: Gruvbox theme, LSP support, fuzzy finding, Treesitter, GitSigns
- Custom aliases for common commands
- Platform-specific configurations for macOS and Arch (btw) Linux (btw)

## License

MIT
