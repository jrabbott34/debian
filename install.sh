#!/usr/bin/env bash
# Debian i3 daily-driver install script
# Supports: Debian 12 (Bookworm) and Debian 13 (Trixie)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
ok()    { echo -e "\033[1;32m[ OK ]\033[0m  $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
die()   { echo -e "\033[1;31m[FAIL]\033[0m  $*"; exit 1; }

# github_latest <owner/repo> — prints the latest tag, empty string on failure
github_latest() {
    curl -fsSL --max-time 15 \
        "https://api.github.com/repos/$1/releases/latest" \
        2>/dev/null | jq -r '.tag_name // empty' 2>/dev/null || true
}

[[ $EUID -ne 0 ]] && die "Run as root (sudo $0)"

export DEBIAN_FRONTEND=noninteractive

# ── Detect Debian version ─────────────────────────────────────────────────────

CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

case "$CODENAME" in
    bookworm) DEBIAN_VER=12 ;;
    trixie)   DEBIAN_VER=13 ;;
    *)        die "Unsupported Debian release: $CODENAME (need bookworm or trixie)" ;;
esac

info "Detected Debian $DEBIAN_VER ($CODENAME)"
BACKPORTS="${CODENAME}-backports"

# ── Fix sources.list ──────────────────────────────────────────────────────────

if grep -q '^deb cdrom:' /etc/apt/sources.list 2>/dev/null; then
    info "Removing DVD/CD-ROM apt source..."
    sed -i 's|^deb cdrom:|#deb cdrom:|g' /etc/apt/sources.list
fi

info "Writing clean sources.list with contrib/non-free..."
cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian ${CODENAME} main contrib non-free non-free-firmware
deb http://deb.debian.org/debian ${CODENAME}-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
EOF

cat > /etc/apt/sources.list.d/backports.list <<EOF
deb http://deb.debian.org/debian ${BACKPORTS} main contrib non-free non-free-firmware
EOF

# ── Bootstrap ─────────────────────────────────────────────────────────────────

apt-get update -qq
info "Installing bootstrap tools..."
apt-get install -y curl wget git jq unzip ca-certificates gnupg cabextract

# ── Mozilla Firefox repo ──────────────────────────────────────────────────────

info "Adding Mozilla Firefox repo..."
install -d -m 0755 /etc/apt/keyrings
FIREFOX_PKG="firefox-esr"
if curl -fsSL --max-time 15 https://packages.mozilla.org/apt/repo-signing-key.gpg \
        -o /etc/apt/keyrings/packages.mozilla.org.asc 2>/dev/null; then
    cat > /etc/apt/sources.list.d/mozilla.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main
EOF
    cat > /etc/apt/preferences.d/mozilla <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1001
EOF
    FIREFOX_PKG="firefox"
    ok "Mozilla Firefox repo added"
else
    warn "Mozilla repo unavailable — using firefox-esr from Debian repos"
fi

apt-get update -qq

# ── Per-version package names ─────────────────────────────────────────────────

CPU_VENDOR=$(grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}')
case "$CPU_VENDOR" in
    GenuineIntel) MICROCODE_PKG="intel-microcode" ;;
    AuthenticAMD) MICROCODE_PKG="amd64-microcode" ;;
    *)            MICROCODE_PKG="" ;;
esac

FREERDP_PKG="freerdp2-x11"
[[ $DEBIAN_VER -ge 13 ]] && FREERDP_PKG="freerdp3-x11"

# ── Core X11 + i3 ─────────────────────────────────────────────────────────────

info "Installing X11 + i3 stack..."
apt-get install -y \
    xorg xinit xserver-xorg \
    i3-wm i3lock i3status \
    polybar rofi picom \
    feh nitrogen dunst libnotify-bin \
    xss-lock xclip xsel xdotool xprintidle \
    arandr autorandr flameshot scrot \
    redshift lxappearance qt5ct qt6ct \
    xdg-desktop-portal-gtk xdg-user-dirs

# ── Nala ──────────────────────────────────────────────────────────────────────

info "Installing nala..."
apt-get install -y nala

# ── Fastfetch ─────────────────────────────────────────────────────────────────

info "Installing fastfetch..."
if ! apt-get install -y fastfetch 2>/dev/null; then
    VER=$(github_latest "fastfetch-cli/fastfetch")
    if [[ -n "$VER" ]]; then
        curl -fsSL --max-time 60 \
            "https://github.com/fastfetch-cli/fastfetch/releases/download/${VER}/fastfetch-linux-amd64.deb" \
            -o /tmp/fastfetch.deb \
        && apt-get install -y /tmp/fastfetch.deb \
        && ok "fastfetch installed from GitHub" \
        || warn "fastfetch install failed — skipping"
        rm -f /tmp/fastfetch.deb
    else
        warn "fastfetch GitHub lookup failed — skipping"
    fi
fi

# ── Speedtest ─────────────────────────────────────────────────────────────────

info "Installing speedtest-cli..."
apt-get install -y speedtest-cli || warn "speedtest-cli unavailable — skipping"

# ── Display Manager ───────────────────────────────────────────────────────────

info "Installing LightDM..."
apt-get install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
systemctl enable lightdm

# ── Fonts ─────────────────────────────────────────────────────────────────────

info "Installing fonts..."
apt-get install -y \
    fonts-font-awesome fonts-powerline fonts-firacode \
    fonts-noto fonts-noto-color-emoji

info "Installing MS core fonts..."
MS_FONTS_DIR=$(mktemp -d)
FONT_DEST="/usr/local/share/fonts/ms-fonts"
mkdir -p "$FONT_DEST"
for font in andale32.exe arial32.exe arialb32.exe comic32.exe courie32.exe \
            georgi32.exe impact32.exe times32.exe trebuc32.exe verdan32.exe webdin32.exe; do
    curl -fsSL --max-time 30 \
        "https://downloads.sourceforge.net/corefonts/${font}" \
        -o "$MS_FONTS_DIR/${font}" 2>/dev/null \
    && cabextract -q -d "$FONT_DEST" "$MS_FONTS_DIR/${font}" 2>/dev/null \
    || true
done
fc-cache -f "$FONT_DEST" 2>/dev/null || true
rm -rf "$MS_FONTS_DIR"
ok "MS fonts done"

info "Installing Nerd Fonts (FiraCode)..."
bash "$SCRIPT_DIR/install-fonts.sh"

# ── Terminals + Shell ─────────────────────────────────────────────────────────

info "Installing terminals and shells..."
apt-get install -y kitty xterm fish zsh zsh-autosuggestions zsh-syntax-highlighting
apt-get install -y alacritty 2>/dev/null \
    && ok "alacritty installed" \
    || warn "alacritty skipped (no GPU/OpenGL — kitty is default)"

# ── System tools ──────────────────────────────────────────────────────────────

info "Installing system tools..."
apt-get install -y \
    htop btop bat acpi sysstat iw yad \
    brightnessctl power-profiles-daemon \
    network-manager network-manager-gnome \
    network-manager-openvpn openvpn \
    gnome-keyring libsecret-tools seahorse \
    policykit-1-gnome golang \
    dosfstools gnome-disk-utility smartmontools

# ── eza ───────────────────────────────────────────────────────────────────────

info "Installing eza..."
if ! apt-get install -y eza 2>/dev/null && \
   ! apt-get install -y -t "${BACKPORTS}" eza 2>/dev/null; then
    VER=$(github_latest "eza-community/eza")
    if [[ -n "$VER" ]]; then
        curl -fsSL --max-time 60 \
            "https://github.com/eza-community/eza/releases/download/${VER}/eza_x86_64-unknown-linux-musl.tar.gz" \
            | tar -xz -C /usr/local/bin \
        && ok "eza installed from GitHub" \
        || warn "eza install failed — skipping"
    else
        warn "eza not available — skipping"
    fi
fi

# ── yazi ──────────────────────────────────────────────────────────────────────

info "Installing yazi..."
YAZI_VER=$(github_latest "sxyazi/yazi")
if [[ -n "$YAZI_VER" ]]; then
    curl -fsSL --max-time 60 \
        "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/yazi-x86_64-unknown-linux-musl.zip" \
        -o /tmp/yazi.zip \
    && unzip -q /tmp/yazi.zip -d /tmp/yazi-extract/ \
    && install -m 755 /tmp/yazi-extract/yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/yazi \
    && install -m 755 /tmp/yazi-extract/yazi-x86_64-unknown-linux-musl/ya /usr/local/bin/ya \
    && ok "yazi installed" \
    || warn "yazi install failed — skipping"
    rm -rf /tmp/yazi.zip /tmp/yazi-extract
else
    warn "yazi GitHub lookup failed — skipping"
fi

# ── Audio ─────────────────────────────────────────────────────────────────────

info "Installing PipeWire..."
apt-get install -y \
    pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol pamixer

# ── Multimedia ────────────────────────────────────────────────────────────────

info "Installing multimedia..."
apt-get install -y mpv cava yt-dlp ffmpeg

# ── File manager ──────────────────────────────────────────────────────────────

info "Installing Thunar and desktop utils..."
apt-get install -y \
    thunar thunar-volman thunar-archive-plugin \
    gvfs gvfs-backends gvfs-fuse \
    samba tumbler xfce4-settings xfce4-notifyd xarchiver

# ── Apps ──────────────────────────────────────────────────────────────────────

info "Installing daily apps..."
apt-get install -y \
    "$FIREFOX_PKG" thunderbird \
    libreoffice libreoffice-gtk3 \
    gedit mousepad timeshift \
    remmina "$FREERDP_PKG" \
    virt-manager qemu-system-x86 qemu-utils \
    libvirt-daemon-system libvirt-clients ovmf \
    dnsmasq nftables \
    qemu-guest-agent spice-vdagent virt-viewer \
    firmware-linux firmware-linux-nonfree \
    bluez bluetooth blueman

# ── CPU microcode ─────────────────────────────────────────────────────────────

if [[ -n "$MICROCODE_PKG" ]]; then
    info "Installing $MICROCODE_PKG..."
    apt-get install -y "$MICROCODE_PKG" || warn "$MICROCODE_PKG unavailable — skipping"
fi

# ── Touchpad (tap to click) ───────────────────────────────────────────────────

info "Configuring touchpad..."
apt-get install -y xserver-xorg-input-libinput
mkdir -p /etc/X11/xorg.conf.d
cp "$SCRIPT_DIR/configs/xorg/40-touchpad.conf" /etc/X11/xorg.conf.d/40-touchpad.conf
ok "Tap to click enabled"

# ── Services ──────────────────────────────────────────────────────────────────

systemctl enable bluetooth NetworkManager

if grep -q "allow-hotplug\|^auto " /etc/network/interfaces 2>/dev/null; then
    cp /etc/network/interfaces /etc/network/interfaces.bak
    cat > /etc/network/interfaces <<'EOF'
# Managed by NetworkManager
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
EOF
fi

# ── Groups ────────────────────────────────────────────────────────────────────

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || true)}"
if [[ -n "$REAL_USER" ]]; then
    usermod -aG libvirt,libvirt-qemu,kvm,video,audio,plugdev,netdev "$REAL_USER" || true
    ok "Added $REAL_USER to required groups"
fi

# ── Dotfiles ──────────────────────────────────────────────────────────────────

if [[ -n "$REAL_USER" ]]; then
    info "Installing dotfiles for $REAL_USER..."
    USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
    bash "$SCRIPT_DIR/setup-symlinks.sh" "$REAL_USER" "$USER_HOME"
fi

ok "Installation complete on Debian $DEBIAN_VER ($CODENAME). Reboot and log in via LightDM."
echo ""
echo "  Post-reboot:"
echo "  - Set wallpaper: nitrogen ~/.config/wallpapers"
echo "  - Save monitor layout: autorandr --detect"
echo "  - Weather in polybar: wttr.in Louisville KY"
