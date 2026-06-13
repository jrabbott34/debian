#!/usr/bin/env bash
# Install FiraCode Nerd Font — can be run standalone or called from install.sh

info()  { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
ok()    { echo -e "\033[1;32m[ OK ]\033[0m  $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m  $*"; }

FONT_DIR="/usr/local/share/fonts/nerd-fonts/FiraCode"
mkdir -p "$FONT_DIR"

# Try latest release first, fall back to known good version
NERD_VER=$(curl -fsSL --max-time 15 \
    https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    2>/dev/null | jq -r '.tag_name // empty' 2>/dev/null || true)

[[ -z "$NERD_VER" ]] && NERD_VER="v3.2.1"

info "Installing FiraCode Nerd Font $NERD_VER..."

TMP=$(mktemp -d)
curl -fsSL --max-time 120 \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VER}/FiraCode.zip" \
    -o "$TMP/FiraCode.zip" \
|| {
    warn "GitHub download failed, trying direct fallback..."
    curl -fsSL --max-time 120 \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip" \
        -o "$TMP/FiraCode.zip"
}

unzip -q "$TMP/FiraCode.zip" -d "$FONT_DIR/"
fc-cache -f
rm -rf "$TMP"

ok "FiraCode Nerd Font installed. Verify with: fc-list | grep -i firacode"
fc-list | grep -i firacode | head -5
