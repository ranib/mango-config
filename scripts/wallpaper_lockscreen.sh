#!/bin/bash

# Extract the active wallpaper path currently rendering via swww
CURRENT_WALLPAPER=$(swww query | grep -oE '/home/[^ ]+\.(jpg|jpeg|png)' | head -n 1)

# Safe fallback asset path if swww isn't initialized yet
DEFAULT_WALLPAPER="$HOME/.config/mango/wallpapers/default.jpg"

if [ -z "$CURRENT_WALLPAPER" ] || [ ! -f "$CURRENT_WALLPAPER" ]; then
    CURRENT_WALLPAPER="$DEFAULT_WALLPAPER"
fi

# Lock the desktop injecting the active background on the fly
veila lock --theme default --background "$CURRENT_WALLPAPER"
