export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="avit"


source $ZSH/oh-my-zsh.sh
# source ~/emsdk/emsdk_env.sh
plugins=(git zsh-autosuggestions z)

[[ -f "$HOME/.config/zsh/aliases" ]] && source "$HOME/.config/zsh/aliases"

[[ -f "$HOME/.config/secrets/secrets" ]] && source "$HOME/.config/secrets/secrets"

if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f "$HOME/.config/zsh/macos" ]] && source "$HOME/.config/zsh/macos"
elif [[ -f "/etc/arch-release" ]]; then
    [[ -f "$HOME/.config/zsh/arch" ]] && source "$HOME/.config/zsh/arch" 
fi
