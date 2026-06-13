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
    # Back up any existing non-symlink file
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "${dst}.bak"
        echo "  backed up: ${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    chown -h "$REAL_USER:$REAL_USER" "$dst"
    echo "  linked: $dst -> $src"
}

link "$CONFIGS/i3"              "$USER_HOME/.config/i3"
link "$CONFIGS/polybar"         "$USER_HOME/.config/polybar"
link "$CONFIGS/rofi"            "$USER_HOME/.config/rofi"
link "$CONFIGS/dunst"           "$USER_HOME/.config/dunst"
link "$CONFIGS/alacritty"       "$USER_HOME/.config/alacritty"
link "$CONFIGS/picom"           "$USER_HOME/.config/picom"

# Autostart PipeWire via user service (enable for real user)
as_user systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true

# Create wallpapers dir
as_user mkdir -p "$USER_HOME/.config/wallpapers"

echo "Dotfiles linked for $REAL_USER."
