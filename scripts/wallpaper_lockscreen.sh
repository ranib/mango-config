#!/usr/bin/env bash

# Query awww to see which picture asset path is currently rendered on screen
CURRENT_WALLPAPER=$(awww query | grep -oE '/home/[^ ]+\.(jpg|jpeg|png|webp)' | head -n 1)

# Safe fallback image pointing inside your repository directory
DEFAULT_WALLPAPER="$HOME/.config/mango/wallpapers/default.jpg"

if [ -z "$CURRENT_WALLPAPER" ] || [ ! -f "$CURRENT_WALLPAPER" ]; then
    CURRENT_WALLPAPER="$DEFAULT_WALLPAPER"
fi

# Trigger Veila desktop secure locker using your native active display background
veila lock --theme default --background "$CURRENT_WALLPAPER"
