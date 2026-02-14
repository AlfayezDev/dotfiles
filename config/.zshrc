# Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="avit"
plugins=(git zsh-autosuggestions z)
source "$ZSH/oh-my-zsh.sh"

# fnm (Fast Node Manager) — replaces nvm
eval "$(fnm env --use-on-cd --shell zsh)"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"

# Additional tools
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.maestro/bin"
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# OVM (Odin Version Manager)
export OVM_INSTALL="$HOME/.ovm/self"
export PATH="$HOME/.ovm/bin:$PATH"

# Node.js
export NODE_EXTRA_CA_CERTS="$HOME/mycerts.pem"

# App environment
export APP__ENV=development

# Aliases & secrets
[[ -f "$HOME/.config/zsh/aliases" ]] && source "$HOME/.config/zsh/aliases"
[[ -f "$HOME/.config/secrets/secrets" ]] && source "$HOME/.config/secrets/secrets"
