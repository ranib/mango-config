#!/bin/bash

# Find the exact wallpaper currently active on your display via swww
CURRENT_WALLPAPER=$(swww query | grep -oE '/home/[^ ]+\.(jpg|jpeg|png)' | head -n 1)

# Fallback path if swww isn't running or can't find an image
DEFAULT_WALLPAPER="$HOME/.config/mango/wallpapers/default.jpg"

if [ -z "$CURRENT_WALLPAPER" ] || [ ! -f "$CURRENT_WALLPAPER" ]; then
    CURRENT_WALLPAPER="$DEFAULT_WALLPAPER"
fi

# Fire veila and inject the active wallpaper on the fly
# Note: You can swap "default" out for any of Veila's 10 built-in theme presets!
veila lock --theme default --background "$CURRENT_WALLPAPER"
