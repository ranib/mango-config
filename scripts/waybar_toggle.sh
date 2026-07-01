#!/usr/bin/env bash

# ==========================================================================
# Waybar Status Panel Visibility Toggle Script
# ==========================================================================

# Check if an instance of Waybar is actively running
if pgrep -x "waybar" > /dev/null; then
    pkill -x waybar
    echo "✓ Waybar hidden"
else
    # Appending the ampersand (&) forces it to run asynchronously in the background
    waybar -c ~/.config/mango/waybar/config.jsonc -s ~/.config/mango/waybar/style.css >/dev/null 2>&1 &
    echo "✓ Waybar initialized"
fi
