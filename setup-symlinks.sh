#!/usr/bin/env bash
# Install dotfiles by symlinking configs into user's home
set -euo pipefail

REAL_USER="${1:-${SUDO_USER:-$(logname 2>/dev/null)}}"
USER_HOME="${2:-$(getent passwd "$REAL_USER" | cut -d: -f6)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS="$SCRIPT_DIR/configs"

as_user() { sudo -u "$REAL_USER" "$@"; }

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "${dst}.bak"
        echo "  backed up: ${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    chown -h "$REAL_USER:$REAL_USER" "$dst"
    echo "  linked: $dst -> $src"
}

append_once() {
    local snippet="$1" target="$2" marker="$3"
    if ! grep -qF "$marker" "$target" 2>/dev/null; then
        echo "" >> "$target"
        echo "$marker" >> "$target"
        cat "$snippet" >> "$target"
        chown "$REAL_USER:$REAL_USER" "$target"
        echo "  appended: $target"
    else
        echo "  already present: $target"
    fi
}

# ── XDG config dirs ───────────────────────────────────────────────────────────
link "$CONFIGS/i3"              "$USER_HOME/.config/i3"
link "$CONFIGS/polybar"         "$USER_HOME/.config/polybar"
link "$CONFIGS/rofi"            "$USER_HOME/.config/rofi"
link "$CONFIGS/dunst"           "$USER_HOME/.config/dunst"
link "$CONFIGS/alacritty"       "$USER_HOME/.config/alacritty"
link "$CONFIGS/picom"           "$USER_HOME/.config/picom"
link "$CONFIGS/fastfetch"       "$USER_HOME/.config/fastfetch"
link "$CONFIGS/shell"           "$USER_HOME/.config/shell"

# ── Fish conf.d ───────────────────────────────────────────────────────────────
as_user mkdir -p "$USER_HOME/.config/fish/conf.d"
link "$CONFIGS/shell/fish_aliases.fish" "$USER_HOME/.config/fish/conf.d/aliases.fish"

# ── Bash ──────────────────────────────────────────────────────────────────────
touch "$USER_HOME/.bashrc"
append_once "$CONFIGS/shell/bashrc_append.sh" \
    "$USER_HOME/.bashrc" \
    "# >>> debian dotfiles >>>"

# ── Zsh ───────────────────────────────────────────────────────────────────────
touch "$USER_HOME/.zshrc"
append_once "$CONFIGS/shell/zshrc_append.sh" \
    "$USER_HOME/.zshrc" \
    "# >>> debian dotfiles >>>"

# ── Autostart PipeWire ────────────────────────────────────────────────────────
as_user systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true

# ── Home directories ──────────────────────────────────────────────────────────
for dir in Documents Downloads Music Pictures Pictures/Screenshots git; do
    as_user mkdir -p "$USER_HOME/$dir"
    echo "  created: $USER_HOME/$dir"
done

# ── Wallpapers dir ────────────────────────────────────────────────────────────
as_user mkdir -p "$USER_HOME/.config/wallpapers"

echo "Dotfiles linked for $REAL_USER."
