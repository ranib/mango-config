#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/mango/wallpapers"
SWITCHER_SCRIPT="$HOME/.config/mango/scripts/wallpaper_switcher.sh"

# Fail gracefully if your picture media folder is completely missing
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory not found at $WALLPAPER_DIR"
    exit 1
fi

# Select a single random image variant cleanly handling whitespace or extension variations
RANDOM_WP=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

if [ -z "$RANDOM_WP" ]; then
    echo "Error: No compatible image files found inside $WALLPAPER_DIR"
    exit 1
fi

# Forward the path directly into your master configuration script as an argument ($1)
if [ -f "$SWITCHER_SCRIPT" ]; then
    types=(wipe any)
    chosen=${types[$RANDOM % ${#types[@]}]}
    awww img "$RANDOM_WP" --transition-type "$chosen" --transition-fps 60 --transition-bezier 0.33,1.0,0.68,1.0 --transition-duration 1.6
else
    # Fallback option if your switcher file script pathway breaks
    awww img "$RANDOM_WP" --transition-type "fade"
fi
