# debian-sway

Debian 12 (Bookworm) and Debian 13 (Trixie) daily-driver build — Sway + Wayland

Catppuccin Mocha theme throughout. Pill-style Waybar. No GNOME dependencies. Tried to create a fun looking Debian (Wayland) Sway build that sort of has a hyprland feel. Just Sway though, not SwayFX

![Desktop Screenshot](screenshot.png)

## Stack

| Layer | Choice |
|---|---|
| Compositor | Sway (Wayland, i3-compatible) |
| Bar | Waybar (pill-style, Catppuccin Mocha) |
| Launcher | Rofi (Wayland) |
| Terminal | Kitty |
| Notifications | Mako (Catppuccin Mocha) |
| Display manager | LightDM + slick-greeter |
| Boot menu | GRUB (Catppuccin Mocha theme) |
| Audio | PipeWire + WirePlumber |
| Wallpaper | swaybg (Catppuccin wallpapers) |
| File manager | Thunar |
| Shell | Zsh + Starship prompt (Catppuccin Mocha) |
| Lock screen | Swaylock (blurred screenshot) |
| Power profiles | power-profiles-daemon |
| Virtualization | QEMU/KVM + virt-manager |

## Waybar modules

- **Left** — Sway workspace numbers
- **Center** — clock/date; hover for calendar
- **Right** — weather (Louisville, KY; hover for forecast) · network · CPU · RAM · volume · battery · idle inhibitor · tray

## Key bindings (Super = Win key)

| Binding | Action |
|---|---|
| `Super+Return` | Terminal (Kitty) |
| `Super+Space` | App launcher (Rofi) |
| `Super+x` | Power menu (lock/logout/suspend/reboot/shutdown) |
| `Super+Shift+e` | Lock screen (blurred swaylock) |
| `Super+Shift+k` | Show all keybinds (rofi viewer) |
| `Super+q` | Close window |
| `Super+f` | Fullscreen |
| `Super+Shift+f` | Toggle floating |
| `Super+Shift+b` | Toggle Waybar |
| `Super+b` | Firefox (workspace 2) |
| `Super+e` | Thunar (workspace 4) |
| `Super+Shift+w` | Random wallpaper |
| `Super+Shift+r` | Reload Sway config |
| `Super+r` | Resize mode |
| `Super+1–0` | Switch workspace |
| `Super+Shift+1–0` | Move window to workspace |
| `Super+drag (right-click)` | Resize window |
| `Print` | Screenshot (full) |
| `Super+Print` | Screenshot (region) |
| `Super+Shift+Print` | Screenshot to clipboard |
| 3-finger swipe left/right | Switch workspace (wraps 1–10) |
| `XF86AudioRaiseVolume/Lower/Mute` | Volume + OSD indicator |
| `XF86MonBrightnessUp/Down` | Brightness + OSD indicator |
| Network icon right-click | Open nmtui (floating) |

## Shell aliases

| Alias | Command |
|---|---|
| `c` | `clear` |
| `update` | `sudo nala update && upgrade` |
| `install` | `sudo nala install` |
| `speedtest` | `speedtest-cli --simple` |
| `swayconfig` | `vim ~/.config/sway/config` |
| `waybarconfig` | `vim ~/.config/waybar/config.jsonc` |
| `ff` | `fastfetch` |
| `ls` / `ll` / `lt` | `eza` with icons |
| `cat` | `bat --style=plain` |

## Install

Start from a minimal Debian install (no desktop environment selected in tasksel).

```bash
sudo apt install git -y
git clone https://github.com/jrabbott34/debian ~/git/debian
cd ~/git/debian
sudo bash install.sh
```

Reboot, select **Sway** from the LightDM session menu, log in.

## Layout

```
configs/
├── sway/
│   ├── config                  # keybinds, window rules, input, autostart
│   └── scripts/
│       ├── bg.sh               # swaybg wallpaper (--random flag)
│       ├── lock.sh             # blurred swaylock (grim + imagemagick)
│       ├── osd.sh              # volume/brightness OSD via mako
│       ├── keybinds.sh         # rofi keybind viewer
│       └── workspace-nav.sh    # swipe to empty workspaces (wraps 1–10)
├── waybar/
│   ├── config.jsonc            # persistent workspaces 1–5, battery, power-profiles
│   ├── style.css               # Catppuccin Mocha pills, transparent bar
│   └── scripts/
│       ├── weather.sh          # wttr.in Louisville KY (JSON + 7-day tooltip)
│       └── calendar-popup.sh   # yad calendar toggle
├── rofi/
│   ├── config.rasi
│   ├── catppuccin-mocha.rasi
│   └── scripts/powermenu.sh    # lock/logout/suspend/reboot/shutdown with icons
├── kitty/kitty.conf            # font size 16, no close prompt, Catppuccin
├── swaylock/config             # Catppuccin Mocha colors
├── mako/config                 # Catppuccin Mocha, OSD app-name group
├── lightdm/slick-greeter.conf  # slick-greeter with dark theme
├── starship/starship.toml      # Catppuccin Mocha powerline segments
└── shell/
    ├── aliases.sh
    └── zshrc                   # zsh + autosuggestions + syntax highlighting
```
