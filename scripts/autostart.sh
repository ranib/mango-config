#!/usr/bin/env bash

# ==========================================================================
# MangoWM System Session Autostart Routine — Script File
# ==========================================================================

# ── 1. Wayland & D-Bus Environment Handlers ────────────────────────────────
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots &

# Initialize security polkit layers to allow admin privilege prompts
/usr/lib/xfce4/notifyd/xfce4-notifyd & 
/usr/lib/xfce-polkit/xfce-polkit &

# ── 2. XDG Desktop Portal Initialization ──────────────────────────────────
killall -q xdg-desktop-portal-wlr xdg-desktop-portal
sleep 0.5
/usr/lib/xdg-desktop-portal-wlr &
sleep 0.5
/usr/lib/xdg-desktop-portal &

# ── 3. Sound & System Status Micro-Daemons ────────────────────────────────
gentle_run() {
    pgrep -x "$1" > /dev/null || "$@" &
}

# Core Pipewire Audio Server Architecture
gentle_run pipewire
gentle_run wireplumber
gentle_run pipewire-pulse

# Clipboard History Daemons
gentle_run wl-paste --type text --watch cliphist store
gentle_run wl-paste --type image --watch cliphist store

# Network Manager applet
gentle_run nm-applet --indicator

# ── 4. UI Elements & Panel Bars ──────────────────────────────────────────
swaync -c ~/.config/mango/swaync/config.jsonc -s ~/.config/mango/swaync/style.css >/dev/null 2>&1 &
waybar -c ~/.config/mango/waybar/config.jsonc -s ~/.config/mango/waybar/style.css >/dev/null 2>&1 &

# ── 5. Wallpaper & Idle Lockscreen Services ──────────────────────────────
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.5
fi

# Load custom randomized wallpaper from your repo on boot
bash ~/.config/mango/scripts/wallpaper_random.sh &

# Initialize user-space service background daemon for Veila locker
systemctl --user enable --now veilad.service

# Launch the idle listener
swayidle -w &

# Run a quick check on your configuration files right at boot
bash ~/.config/mango/scripts/config_check.sh &
