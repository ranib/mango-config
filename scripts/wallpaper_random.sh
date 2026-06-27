#!/bin/env bash

WALL_DIR="$HOME/Pictures/Wallpapers"

# 1. Verify the directory exists and has files
if [ ! -d "$WALL_DIR" ] || [ -z "$(ls -A "$WALL_DIR")" ]; then
    echo "[ERROR] Wallpaper directory is empty or does not exist."
    exit 1
fi

# 2. Select random wallpaper
WALL=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

types=(wipe any)
chosen=${types[$RANDOM % ${#types[@]}]}

# Set main wallpaper
awww img "$WALL" --transition-type "$chosen" --transition-fps 60 --transition-bezier 0.33,1.0,0.68,1.0 --transition-duration 1.6

# 3. Handle the blurred background (using unique PID to prevent caching)
MANGO="/tmp/blurred_wall_$$ .jpg"

status=$(ps -C mango -o comm=)
if [[ $status == "mango" ]]; then
  
  # Generate unique blurred image
  ffmpeg -y -i "$WALL" -vf "format=yuv420p,gblur=sigma=10,eq=contrast=1.1:saturation=1.4" -update 1 "$MANGO" -loglevel error
  
  # Check socket and apply
  if [[ -S "/run/user/1000/wayland-0-awww-daemon.mango.sock" ]]; then
    awww img --namespace mango "$MANGO" --transition-type "$chosen" --transition-fps 60 --transition-bezier 0.33,1.0,0.68,1.0 --transition-duration 1.6
    
    # Small delay to let awww load it, then clean up the temp file
    (sleep 2 && rm -f "$MANGO") &
  else
    echo "[WARN] awww-daemon mango socket not found. Skipping blurred background."
    rm -f "$MANGO"
  fi
fi
