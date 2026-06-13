#!/usr/bin/env bash
set -euo pipefail

# Debian i3 daily-driver install script
# Supports: Debian 12 (Bookworm) and Debian 13 (Trixie)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
ok()    { echo -e "\033[1;32m[ OK ]\033[0m  $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
die()   { echo -e "\033[1;31m[FAIL]\033[0m  $*"; exit 1; }

[[ $EUID -ne 0 ]] && die "Run as root (sudo $0)"

export DEBIAN_FRONTEND=noninteractive

# ── Detect Debian version ─────────────────────────────────────────────────────

CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
VERSION_ID=$(grep ^VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"')

case "$CODENAME" in
    bookworm) DEBIAN_VER=12 ;;
    trixie)   DEBIAN_VER=13 ;;
    *)        die "Unsupported Debian release: $CODENAME (need bookworm or trixie)" ;;
esac

info "Detected Debian $DEBIAN_VER ($CODENAME)"

BACKPORTS="${CODENAME}-backports"

# ── Repos ─────────────────────────────────────────────────────────────────────

# Remove DVD/CD-ROM source — the installer adds this and apt will prompt for
# the disc on every operation if it's left in.
if grep -q '^deb cdrom:' /etc/apt/sources.list 2>/dev/null; then
    info "Removing DVD/CD-ROM apt source..."
    sed -i 's|^deb cdrom:|#deb cdrom:|g' /etc/apt/sources.list
    ok "CD-ROM source commented out"
fi

# If sources.list has no network mirror at all (install was done fully offline),
# add the standard Debian mirror now so the rest of the script can proceed.
if ! grep -q "^deb http" /etc/apt/sources.list 2>/dev/null; then
    info "No network mirror found — adding Debian mirror for $CODENAME..."
    cat >> /etc/apt/sources.list <<EOF

deb http://deb.debian.org/debian ${CODENAME} main
deb http://deb.debian.org/debian ${CODENAME}-updates main
deb http://security.debian.org/debian-security ${CODENAME}-security main
EOF
fi

info "Enabling contrib/non-free/non-free-firmware..."
sed -i "s|^deb \(.*\) ${CODENAME} main\$|deb \1 ${CODENAME} main contrib non-free non-free-firmware|" /etc/apt/sources.list
sed -i "s|^deb \(.*\) ${CODENAME}-updates main\$|deb \1 ${CODENAME}-updates main contrib non-free non-free-firmware|" /etc/apt/sources.list 2>/dev/null || true

info "Adding backports ($BACKPORTS)..."
cat > /etc/apt/sources.list.d/backports.list <<EOF
deb http://deb.debian.org/debian ${BACKPORTS} main contrib non-free non-free-firmware
EOF

info "Adding Mozilla Firefox repo..."
install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
    -o /etc/apt/keyrings/packages.mozilla.org.asc
cat > /etc/apt/sources.list.d/mozilla.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main
EOF
cat > /etc/apt/preferences.d/mozilla <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1001
EOF

apt-get update -qq

# ── Bootstrap tools (needed before everything else) ───────────────────────────
# curl/jq/unzip are used by later GitHub download blocks — install them first.

info "Installing bootstrap tools..."
apt-get install -y curl wget git jq unzip

# ── CPU microcode (auto-detect Intel vs AMD) ──────────────────────────────────

CPU_VENDOR=$(grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}')
case "$CPU_VENDOR" in
    GenuineIntel) MICROCODE_PKG="intel-microcode" ;;
    AuthenticAMD) MICROCODE_PKG="amd64-microcode" ;;
    *)
        warn "Unknown CPU vendor '$CPU_VENDOR', skipping microcode"
        MICROCODE_PKG=""
        ;;
esac

# ── freerdp package name changed in Debian 13 ────────────────────────────────

if [[ $DEBIAN_VER -ge 13 ]]; then
    FREERDP_PKG="freerdp3-x11"
else
    FREERDP_PKG="freerdp2-x11"
fi

# ── Core X11 + i3 ─────────────────────────────────────────────────────────────

info "Installing X11 + i3 stack..."
apt-get install -y \
    xorg \
    xinit \
    xserver-xorg \
    i3-wm \
    i3lock \
    i3status \
    polybar \
    rofi \
    picom \
    feh \
    nitrogen \
    dunst \
    libnotify-bin \
    xss-lock \
    xclip \
    xsel \
    xdotool \
    arandr \
    autorandr \
    flameshot \
    scrot \
    redshift \
    lxappearance \
    qt5ct \
    qt6ct \
    xdg-desktop-portal-gtk \
    xdg-user-dirs

# ── xidlehook (idle screen-blank / lock trigger) ─────────────────────────────
# Not in Debian repos — best-effort install from GitHub. xss-lock still handles
# lock-on-suspend without it; this just adds idle-timeout auto-lock.

info "Installing xidlehook (optional)..."
XIDLEHOOK_VER=$(curl -fsSL --max-time 10 \
    https://api.github.com/repos/jD91mZM2/xidlehook/releases/latest \
    | jq -r '.tag_name // empty' 2>/dev/null || true)
if [[ -n "$XIDLEHOOK_VER" ]]; then
    curl -fsSL --max-time 30 \
        "https://github.com/jD91mZM2/xidlehook/releases/download/${XIDLEHOOK_VER}/xidlehook-x86_64-unknown-linux-musl.tar.gz" \
        | tar -xz -C /usr/local/bin xidlehook 2>/dev/null \
    && ok "xidlehook installed" || warn "xidlehook download failed — skipping (non-fatal)"
else
    warn "xidlehook release lookup failed — skipping (non-fatal)"
fi

# ── Nala (apt frontend) ───────────────────────────────────────────────────────

info "Installing nala..."
apt-get install -y nala

# ── Fastfetch ─────────────────────────────────────────────────────────────────

info "Installing fastfetch..."
# Try apt first (available in Trixie main), fall back to GitHub .deb
if apt-get install -y fastfetch 2>/dev/null; then
    ok "fastfetch installed via apt"
else
    FASTFETCH_VER=$(curl -fsSL https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | jq -r .tag_name)
    curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/download/${FASTFETCH_VER}/fastfetch-linux-amd64.deb" \
        -o /tmp/fastfetch.deb
    apt-get install -y /tmp/fastfetch.deb
    rm -f /tmp/fastfetch.deb
fi

# ── Speedtest ─────────────────────────────────────────────────────────────────

info "Installing speedtest-cli..."
apt-get install -y speedtest-cli

# ── Display Manager ───────────────────────────────────────────────────────────

info "Installing LightDM..."
apt-get install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
systemctl enable lightdm

# ── Fonts ─────────────────────────────────────────────────────────────────────

info "Installing fonts..."
apt-get install -y \
    fonts-font-awesome \
    fonts-powerline \
    fonts-firacode \
    fonts-noto \
    fonts-noto-color-emoji \
    ttf-mscorefonts-installer

info "Installing Nerd Fonts (FiraCode)..."
NERD_VER=$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r .tag_name)
TMP_FONTS=$(mktemp -d)
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VER}/FiraCode.zip" \
    -o "$TMP_FONTS/FiraCode.zip"
mkdir -p /usr/local/share/fonts/nerd-fonts
unzip -q "$TMP_FONTS/FiraCode.zip" -d /usr/local/share/fonts/nerd-fonts/FiraCode/
fc-cache -f
rm -rf "$TMP_FONTS"

# ── Terminal + Shell ──────────────────────────────────────────────────────────

info "Installing terminals and shells..."
apt-get install -y \
    alacritty \
    fish \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting

# ── System tools ──────────────────────────────────────────────────────────────

info "Installing system tools..."
apt-get install -y \
    curl \
    wget \
    git \
    htop \
    btop \
    bat \
    acpi \
    sysstat \
    iw \
    jq \
    yad \
    brightnessctl \
    power-profiles-daemon \
    network-manager \
    network-manager-gnome \
    network-manager-openvpn \
    openvpn \
    gnome-keyring \
    libsecret-tools \
    seahorse \
    policykit-1-gnome \
    golang \
    dosfstools \
    gnome-disk-utility \
    smartmontools

# ── eza ───────────────────────────────────────────────────────────────────────

info "Installing eza..."
# In Trixie eza is in main; in Bookworm it needs backports
if apt-get install -y eza 2>/dev/null; then
    ok "eza installed via apt"
elif apt-get install -y -t "${BACKPORTS}" eza 2>/dev/null; then
    ok "eza installed via backports"
else
    warn "eza not in repos, installing from GitHub release..."
    EZA_VER=$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest | jq -r .tag_name)
    curl -fsSL "https://github.com/eza-community/eza/releases/download/${EZA_VER}/eza_x86_64-unknown-linux-musl.tar.gz" \
        | tar -xz -C /usr/local/bin
fi

# ── yazi (terminal file manager) ──────────────────────────────────────────────

info "Installing yazi from GitHub..."
YAZI_VER=$(curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r .tag_name)
curl -fsSL "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/yazi-x86_64-unknown-linux-musl.zip" \
    -o /tmp/yazi.zip
unzip -q /tmp/yazi.zip -d /tmp/yazi-extract/
install -m 755 /tmp/yazi-extract/yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/yazi
install -m 755 /tmp/yazi-extract/yazi-x86_64-unknown-linux-musl/ya /usr/local/bin/ya
rm -rf /tmp/yazi.zip /tmp/yazi-extract

# ── Audio ─────────────────────────────────────────────────────────────────────

info "Installing PipeWire + PulseAudio compat..."
apt-get install -y \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    pavucontrol \
    pamixer

# ── Multimedia ────────────────────────────────────────────────────────────────

info "Installing multimedia..."
apt-get install -y \
    mpv \
    cava \
    yt-dlp \
    ffmpeg

# ── File manager + desktop utils ──────────────────────────────────────────────

info "Installing Thunar and desktop utils..."
apt-get install -y \
    thunar \
    thunar-volman \
    thunar-archive-plugin \
    gvfs \
    gvfs-backends \
    samba \
    tumbler \
    xfce4-settings \
    xfce4-notifyd \
    xarchiver

# ── Apps ──────────────────────────────────────────────────────────────────────

info "Installing daily apps..."
apt-get install -y \
    firefox \
    thunderbird \
    libreoffice \
    libreoffice-gtk3 \
    gedit \
    mousepad \
    timeshift \
    remmina \
    "$FREERDP_PKG" \
    virt-manager \
    qemu-system-x86 \
    qemu-utils \
    libvirt-daemon-system \
    libvirt-clients \
    ovmf \
    dnsmasq \
    nftables \
    qemu-guest-agent \
    spice-vdagent \
    virt-viewer \
    firmware-linux \
    firmware-linux-nonfree \
    bluez \
    bluetooth \
    blueman

# ── CPU microcode ─────────────────────────────────────────────────────────────

if [[ -n "$MICROCODE_PKG" ]]; then
    info "Installing $MICROCODE_PKG..."
    apt-get install -y "$MICROCODE_PKG"
fi

# ── Bluetooth ─────────────────────────────────────────────────────────────────

systemctl enable bluetooth

# ── Virtualization groups ──────────────────────────────────────────────────────

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
if [[ -n "$REAL_USER" ]]; then
    usermod -aG libvirt,libvirt-qemu,kvm,video,audio,plugdev,netdev "$REAL_USER"
    ok "Added $REAL_USER to required groups"
fi

# ── NetworkManager ────────────────────────────────────────────────────────────

systemctl enable NetworkManager
if grep -q "allow-hotplug\|auto " /etc/network/interfaces 2>/dev/null; then
    cp /etc/network/interfaces /etc/network/interfaces.bak
    cat > /etc/network/interfaces <<'EOF'
# Managed by NetworkManager
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
EOF
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
echo "  - Run: autorandr --detect  (to save monitor layout)"
echo "  - Set wallpaper: nitrogen ~/.config/wallpapers"
echo "  - Weather in polybar uses wttr.in for Louisville, KY"
