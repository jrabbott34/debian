# Shell aliases — sourced by .bashrc, .zshrc, and fish (via a wrapper)

# ── General ───────────────────────────────────────────────────────────────────
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'

# ── Package management (nala) ─────────────────────────────────────────────────
alias update='sudo nala update && sudo nala upgrade'
alias install='sudo nala install'
alias remove='sudo nala remove'
alias search='nala search'
alias autoremove='sudo nala autoremove'

# ── System info ───────────────────────────────────────────────────────────────
alias speedtest='speedtest-cli --simple'
alias ff='fastfetch'

# ── Config shortcuts ──────────────────────────────────────────────────────────
alias swayconfig='vim ~/.config/sway/config'
alias waybarconfig='vim ~/.config/waybar/config.jsonc'
alias aliasrc='vim ~/.config/shell/aliases.sh'

# ── ls → eza ──────────────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -la --git'
alias lt='eza --icons --tree --level=2'

# ── cat → bat ────────────────────────────────────────────────────────────────
alias cat='bat --style=plain'

# ── Safety nets ───────────────────────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ── Misc ──────────────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ip='ip --color=auto'
