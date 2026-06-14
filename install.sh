#!/usr/bin/env bash
# Debian 12/13 Sway/Wayland daily-driver installer

LOGFILE="/tmp/debian-setup-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

need_root() { [ "$(id -u)" -eq 0 ] || { error "Run as root"; exit 1; }; }
need_root

# ── Bootstrap tools ──────────────────────────────────────────────────────────
info "Installing bootstrap tools..."
apt-get update -qq
apt-get install -y curl wget git jq unzip ca-certificates gnupg cabextract apt-transport-https

# ── Detect Debian version ─────────────────────────────────────────────────────
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
info "Detected Debian: $CODENAME"

# ── Clean sources.list ────────────────────────────────────────────────────────
info "Writing sources.list..."
cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian $CODENAME main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian $CODENAME main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security $CODENAME-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security $CODENAME-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian $CODENAME-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian $CODENAME-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian $CODENAME-backports main contrib non-free non-free-firmware
EOF

# Remove cdrom entries if any
sed -i '/^deb cdrom:/d' /etc/apt/sources.list

apt-get update -qq

# ── Microcode ─────────────────────────────────────────────────────────────────
info "Detecting CPU for microcode..."
if grep -q "GenuineIntel" /proc/cpuinfo 2>/dev/null; then
    apt-get install -y intel-microcode || warn "intel-microcode failed"
elif grep -q "AuthenticAMD" /proc/cpuinfo 2>/dev/null; then
    apt-get install -y amd64-microcode || warn "amd64-microcode failed"
fi

# ── GitHub latest helper ──────────────────────────────────────────────────────
github_latest() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
        | jq -r '.tag_name' 2>/dev/null || echo ""
}

# ── Firefox ───────────────────────────────────────────────────────────────────
info "Installing Firefox..."
FIREFOX_OK=0
# Try Mozilla repo first
if curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
        -o /usr/share/keyrings/mozilla.gpg 2>/dev/null; then
    echo "deb [signed-by=/usr/share/keyrings/mozilla.gpg] https://packages.mozilla.org/apt mozilla main" \
        > /etc/apt/sources.list.d/mozilla.list
    cat > /etc/apt/preferences.d/mozilla <<'PREF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1001
PREF
    apt-get update -qq
    apt-get install -y firefox && FIREFOX_OK=1 || warn "Mozilla repo Firefox failed, falling back"
fi
if [ "$FIREFOX_OK" -eq 0 ]; then
    apt-get install -y firefox-esr || warn "firefox-esr also failed"
fi

# ── Core packages ─────────────────────────────────────────────────────────────
info "Installing core Wayland/Sway packages..."
apt-get install -y \
    sway swaylock swayidle swaybg \
    waybar \
    rofi \
    mako-notifier \
    grim slurp \
    wl-clipboard \
    xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    gammastep \
    wlr-randr \
    ydotool \
    qt5-wayland qt6-wayland \
    policykit-1-gnome \
    xwayland \
    kitty xterm foot \
    || warn "Some Wayland packages failed — check log"

info "Installing desktop apps..."
apt-get install -y \
    thunar gvfs gvfs-backends gvfs-fuse samba tumbler \
    xfce4-settings xfce4-notifyd xarchiver \
    mousepad gedit \
    yad \
    lxappearance qt5ct \
    || warn "Some desktop apps failed"

info "Installing audio (PipeWire)..."
apt-get install -y \
    pipewire pipewire-pulse pipewire-alsa wireplumber \
    pavucontrol pamixer \
    || warn "Some audio packages failed"

info "Installing productivity apps..."
apt-get install -y \
    thunderbird libreoffice \
    || warn "Some productivity apps failed"

info "Installing network/bluetooth..."
apt-get install -y \
    network-manager network-manager-gnome \
    bluez bluetooth blueman \
    || warn "Some network/bt packages failed"

info "Installing system utilities..."
apt-get install -y \
    nala fastfetch htop btop \
    brightnessctl \
    gnome-keyring libsecret-tools seahorse \
    || warn "Some utilities failed"

info "Installing speedtest-cli..."
apt-get install -y speedtest-cli || \
    pip3 install speedtest-cli 2>/dev/null || \
    warn "speedtest-cli failed"

info "Installing virtualization packages..."
apt-get install -y \
    qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients \
    virt-manager ovmf bridge-utils \
    || warn "Some virt packages failed"

# ── Display manager ───────────────────────────────────────────────────────────
info "Installing LightDM..."
apt-get install -y lightdm lightdm-gtk-greeter || warn "lightdm failed"

# Create sway session for LightDM
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/sway.desktop <<'EOF'
[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=sway
Type=Application
EOF

# ── Microsoft Fonts ───────────────────────────────────────────────────────────
info "Installing Microsoft core fonts..."
(
    tmpdir=$(mktemp -d)
    cd "$tmpdir"
    wget -q "https://downloads.sourceforge.net/corefonts/arial32.exe" \
         "https://downloads.sourceforge.net/corefonts/times32.exe" \
         "https://downloads.sourceforge.net/corefonts/courie32.exe" 2>/dev/null || true
    for f in *.exe; do
        [ -f "$f" ] && cabextract --lowercase --directory=/usr/share/fonts/truetype/msttcorefonts "$f" 2>/dev/null || true
    done
    fc-cache -f 2>/dev/null || true
    rm -rf "$tmpdir"
) || warn "MS fonts install failed (non-fatal)"

# ── Nerd Fonts via install-fonts.sh ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/install-fonts.sh" ]; then
    info "Running install-fonts.sh..."
    bash "$SCRIPT_DIR/install-fonts.sh" || warn "install-fonts.sh had errors"
fi

# ── Enable services ───────────────────────────────────────────────────────────
info "Enabling services..."
systemctl enable lightdm 2>/dev/null || warn "lightdm enable failed"
systemctl enable NetworkManager 2>/dev/null || warn "NetworkManager enable failed"
systemctl enable bluetooth 2>/dev/null || warn "bluetooth enable failed"
systemctl enable libvirtd 2>/dev/null || warn "libvirtd enable failed"

# Add user to groups
if [ -n "${SUDO_USER:-}" ]; then
    info "Adding $SUDO_USER to groups..."
    for grp in libvirt libvirt-qemu kvm input video audio plugdev bluetooth; do
        usermod -aG "$grp" "$SUDO_USER" 2>/dev/null || true
    done
fi

info "Done! Log saved to $LOGFILE"
info "Reboot and select Sway from the LightDM session menu."
