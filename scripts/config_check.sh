#!/usr/bin/env bash

# ==========================================================================
# MangoWM Configuration Linter & Health Check Script
# ==========================================================================

# Run the parser check and strip ANSI terminal artifacts dynamically
output=$(mango -p 2>&1 | sed -r '
    s/\x1b\[[0-9;]*[a-zA-Z]//g   # Strip ANSI coloring strings
    s/   ╰─/ ╰─/g                # Flatten multi-character spacing arrays
    s/^[[:space:]]*//            # Remove trailing left white space
    s/[[:space:]]*$//            # Remove trailing right white space
')

# Path Corrected: Target your unified asset directory folder
icon="$HOME/.config/mango/wallpapers/default.jpg"

# Exit cleanly if no structural syntax layout mistakes are detected
if [[ -z "$output" ]]; then
    exit 0
fi

# Broadcast a persistent desktop system alert if things are broken
notify-send --urgency=critical --icon="$icon" "Mango Configuration Status" "$output"
