# debian

Debian 12 (Bookworm) daily-driver build — i3 + X11

## Stack

| Layer | Choice |
|---|---|
| WM | i3-wm |
| Bar | Polybar |
| Launcher | Rofi |
| Compositor | Picom (glx) |
| Terminal | Alacritty |
| Notifications | Dunst |
| Display manager | LightDM |
| Audio | PipeWire + PulseAudio compat |
| Wallpaper | Nitrogen |
| File manager | Thunar |

## Polybar modules (left → right)

- **Left** — i3 workspace numbers
- **Center** — clock/date; click opens `yad` calendar popup
- **Right** — weather (Louisville, KY) · CPU · RAM · volume · idle inhibitor · system tray

## Shell aliases

Available in bash, zsh, and fish after install:

| Alias | Command |
|---|---|
| `c` | `clear` |
| `update` | `sudo nala update && sudo nala upgrade` |
| `install` | `sudo nala install` |
| `speedtest` | `speedtest-cli --simple` |
| `i3config` | `gedit ~/.config/i3/config` |
| `polyconfig` | `gedit ~/.config/polybar/config.ini` |
| `ff` | `fastfetch` |
| `ls` / `ll` / `lt` | `eza` with icons |
| `cat` | `bat --style=plain` |

## Install

```bash
sudo bash install.sh
```

Reboot, then log in via LightDM and choose the i3 session.

### Post-reboot

```bash
# Save current monitor layout
autorandr --detect --force

# Set wallpaper
nitrogen ~/.config/wallpapers

# Set GTK theme
lxappearance

# Set Qt theme
qt5ct && qt6ct
```

## Layout

```
configs/
├── i3/           # i3 keybindings, autostart, window rules
├── polybar/
│   ├── config.ini
│   ├── launch.sh
│   └── scripts/
│       ├── weather.sh          # wttr.in Louisville KY
│       ├── calendar-popup.sh   # yad calendar toggle
│       └── idle-inhibitor.sh   # xdotool-based inhibitor
├── rofi/
│   ├── launcher.rasi
│   ├── powermenu.rasi
│   ├── powermenu.sh
│   └── nord.rasi               # shared Nord palette
├── dunst/dunstrc
├── alacritty/alacritty.toml
└── picom/picom.conf
```

## Key bindings (Super = Win key)

| Binding | Action |
|---|---|
| `Super+Return` | Terminal (Alacritty) |
| `Super+space` | App launcher (Rofi) |
| `Super+x` | Power menu (lock/logout/suspend/reboot/shutdown) |
| `Super+l` | Lock screen |
| `Super+q` | Close window |
| `Super+f` | Fullscreen |
| `Super+b` | Firefox |
| `Super+e` | Thunar |
| `Super+Shift+w` | Random wallpaper (nitrogen) |
| `Print` | Screenshot (full) |
| `Super+Print` | Screenshot (region, Flameshot) |
| `Super+r` | Resize mode |
| `Super+Shift+r` | Reload i3 config |
| `Super+1–0` | Switch workspace |
| `Super+Shift+1–0` | Move window to workspace |
