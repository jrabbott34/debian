# Appended by debian dotfiles install

# Source shared aliases
[[ -f "$HOME/.config/shell/aliases.sh" ]] && source "$HOME/.config/shell/aliases.sh"

# zsh-style completions / history
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Launch fastfetch on new terminal (interactive only)
if [[ $- == *i* ]] && command -v fastfetch &>/dev/null; then
    fastfetch
fi
