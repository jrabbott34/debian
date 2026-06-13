# Appended by debian dotfiles install

# Source shared aliases
[[ -f "$HOME/.config/shell/aliases.sh" ]] && source "$HOME/.config/shell/aliases.sh"

# Plugins (Debian paths)
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# Launch fastfetch on new terminal (interactive only)
if [[ $- == *i* ]] && command -v fastfetch &>/dev/null; then
    fastfetch
fi
