# mango-config
my mango config

<img width="1920" height="1080" alt="screenshot-2026-02-08_18:22:24" src="https://github.com/user-attachments/assets/e1795c88-f1a1-4fbe-b97c-51af5419b6c5" />

<img width="1920" height="1080" alt="screenshot-2026-02-08_18:22:33" src="https://github.com/user-attachments/assets/7e1b7510-ad9b-4561-8aaf-6114098e9e28" />


# dependence
I use <a href="https://archbang.org/2026/05/22/want-some-mango-then-try-out-fruitbang/">Fruitbang</a> distro. Pacman will not work until keys are initialized. Run the following: ~/Scripts/fix-keys

## Installation

### One-liner
```bash
sudo pacman -Syu --needed --noconfirm git && cd ~ && git clone https://github.com/ranib/mango-config.git && bash ~/mango-config/install.sh
```

### Manual (incomplete compared to install script)
```bash
yay -S rofi foot xdg-desktop-portal-wlr swaybg waybar wl-clip-persist cliphist wl-clipboard wlsunset xfce-polkit swaync pamixer wlr-dpms sway-audio-idle-inhibit-git swayidle dimland-git brightnessctl swayosd wlr-randr grim slurp satty swaylock-effects-git wlogout sox
```

# Usage
```bash
git clone https://github.com/ranib/mango-config.git ~/.config/mango
```
## Some Common Default Keybindings

- alt+return: open foot terminal
- alt+space: open rofi launcher
- alt+w: wallpaper changer
- alt+t: thunar file manager
- alt+z: zen browser
- alt+q: kill client
- alt+left/right/up/down: focus direction
- super+m: quit mango

