#!/usr/bin/env bash
# Setup symlinks for Sway/Wayland dotfiles

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
    info "Linked $dst → $src"
}

# ── Create standard directories ───────────────────────────────────────────────
info "Creating standard directories..."
mkdir -p ~/Documents ~/Downloads ~/Music ~/Pictures ~/Pictures/Screenshots ~/git
mkdir -p ~/.config/wallpapers

# ── Config symlinks ───────────────────────────────────────────────────────────
info "Linking configs..."
link "$REPO_DIR/configs/sway"       ~/.config/sway
link "$REPO_DIR/configs/waybar"     ~/.config/waybar
link "$REPO_DIR/configs/rofi"       ~/.config/rofi
link "$REPO_DIR/configs/mako"       ~/.config/mako
link "$REPO_DIR/configs/fastfetch"  ~/.config/fastfetch
link "$REPO_DIR/configs/alacritty"  ~/.config/alacritty
link "$REPO_DIR/configs/shell"      ~/.config/shell

# Fish aliases
if [ -d "$REPO_DIR/configs/shell" ]; then
    FISH_CONF_DIR=~/.config/fish/conf.d
    mkdir -p "$FISH_CONF_DIR"
    if [ -f "$REPO_DIR/configs/shell/fish_aliases" ]; then
        link "$REPO_DIR/configs/shell/fish_aliases" "$FISH_CONF_DIR/aliases.fish"
    fi
fi

# ── Shell RC appends ──────────────────────────────────────────────────────────
info "Appending shell configs..."

BASHRC_APPEND="$REPO_DIR/configs/shell/bashrc_append"
if [ -f "$BASHRC_APPEND" ]; then
    MARKER="# debian-dotfiles bashrc"
    if ! grep -qF "$MARKER" ~/.bashrc 2>/dev/null; then
        echo -e "\n$MARKER" >> ~/.bashrc
        cat "$BASHRC_APPEND" >> ~/.bashrc
        info "Appended to ~/.bashrc"
    else
        info "~/.bashrc already has dotfiles block, skipping"
    fi
fi

ZSHRC_APPEND="$REPO_DIR/configs/shell/zshrc_append"
if [ -f "$ZSHRC_APPEND" ]; then
    MARKER="# debian-dotfiles zshrc"
    if ! grep -qF "$MARKER" ~/.zshrc 2>/dev/null; then
        echo -e "\n$MARKER" >> ~/.zshrc
        cat "$ZSHRC_APPEND" >> ~/.zshrc
        info "Appended to ~/.zshrc"
    else
        info "~/.zshrc already has dotfiles block, skipping"
    fi
fi

# ── Nerd Fonts ────────────────────────────────────────────────────────────────
if [ -f "$REPO_DIR/install-fonts.sh" ]; then
    info "Running install-fonts.sh..."
    bash "$REPO_DIR/install-fonts.sh" || warn "install-fonts.sh had errors"
fi

# ── X11 touchpad fallback ─────────────────────────────────────────────────────
TOUCHPAD_CONF="$REPO_DIR/configs/xorg/40-touchpad.conf"
if [ -f "$TOUCHPAD_CONF" ]; then
    sudo mkdir -p /etc/X11/xorg.conf.d/
    sudo cp "$TOUCHPAD_CONF" /etc/X11/xorg.conf.d/40-touchpad.conf
    info "Copied touchpad config to /etc/X11/xorg.conf.d/"
fi

info "All symlinks created!"
info "Wallpapers: drop images in ~/.config/wallpapers/"
info "Reboot or log into a Sway session to apply."
