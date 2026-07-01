# mango-config
my mango config

<img width="1920" height="1080" alt="screenshot-2026-02-08_18:22:24" src="https://github.com/user-attachments/assets/e1795c88-f1a1-4fbe-b97c-51af5419b6c5" />

<img width="1920" height="1080" alt="screenshot-2026-02-08_18:22:33" src="https://github.com/user-attachments/assets/7e1b7510-ad9b-4561-8aaf-6114098e9e28" />


# dependence
I use <a href="https://archbang.org/2026/05/22/want-some-mango-then-try-out-fruitbang/">Fruitbang</a> distro. Pacman will not work until keys are initialized. Run the following: ~/Scripts/fix-keys (I have included this in install script)

## Installation

### One-liner
```bash
sudo pacman -Syu --needed --noconfirm git && cd ~ && git clone https://github.com/ranib/mango-config.git && bash ~/mango-config/install.sh
```

### Manual (incomplete compared to install script)
```bash
yay -S rofi foot xdg-desktop-portal-wlr swaybg waybar wl-clip-persist cliphist wl-clipboard wlsunset xfce-polkit swaync pamixer wlr-dpms sway-audio-idle-inhibit-git swayidle dimland-git brightnessctl swayosd wlr-randr grim slurp satty swaylock-effects-git wlogout sox
```

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

# 🥭 mango-config

An ultra-lightweight, high-performance tiling window manager configuration layout built for **Arch Linux + MangoWM** (`dwl-scenefx`). This repository features a completely self-contained, centralized ecosystem engineered exclusively for modern Wayland protocols.

![Wayland Native](https://shields.io)
![Arch Linux](https://shields.io)

## ✨ Highlight Features
* **Unified Workspace Structure**: The entire ecosystem installs and configures itself cleanly inside `~/.config/mango/`.
* **Modern Inactivity Security**: Screen locking is driven natively via **Veila** and **Swayidle** utilizing the robust `ext-session-lock-v1` security protocol.
* **Dynamic Lock Matching**: Lock screens seamlessly capture whatever background is active on your workspace on the fly via `awww`.
* **Polished Boot Authentication**: Features **SilentSDDM** out-of-the-box, providing an elegant, distraction-free login gateway that matches the core desktop design.
* **Blazingly Fast Terminal Layouts**: Powered strictly by the native **Foot** terminal emulator with integrated **Starship (Pastel Powerline)** prompt arrays.
* **Visual Wallpaper Selection**: Includes an interactive, grid-based Rofi visual thumbnail selector with zero-overhead background transitions.

## 🚀 1-Command Automated Deployment

To cleanly deploy this environment, initialize a fresh, non-root terminal shell window and run the execution string below. The deployment layout script handles key updates, system daemons, core libraries, and user layouts automatically.

```bash
curl -sL https://githubusercontent.com | bash
```

## 🗂️ Core Repository Architecture Map
The centralized repository resolves historical trail-matching bugs by structuring components under uniform subdirectories:

```text
.
├── install.sh                  # Automated system bootstrap engine
└── mango/
    ├── bind.conf               # Hardware keys, apps, and window bindings
    ├── config.conf             # Compositor parameters, gaps, animations
    ├── fastfetch/              # Foot terminal system readouts
    ├── foot/                   # Terminal colors and font profiles
    ├── rofi/                   # Launcher and visual wallpaper picker grids
    ├── scripts/                # Autostart strings and thumbnail managers
    ├── swayidle/               # Inactivity listeners (no extension)
    ├── swaync/                 # Unified system alert panels
    ├── wallpapers/             # Your local asset cache (includes default.jpg)
    ├── waybar/                 # Advanced status modules
    └── wlogout/                # Relative path-mapped system power grid
```

## ⌨️ Critical Desktop Key Combinations
Core workflows map directly to the `SUPER` (Windows) and `ALT` keys layout:

| Key Binding | Target Application/Action |
| :--- | :--- |
| `SUPER` + `Return` | Launch **Foot** Terminal |
| `ALT` + `t` | Open **Thunar** File Manager |
| `SUPER` + `y` | Open **Yazi** Terminal File Manager |
| `ALT` + `Space` | Global **Rofi** App Launcher Menu |
| `SUPER` + `w` | **Rofi Wallpaper Picker GUI** Grid Panel |
| `SUPER` + `.` | Interactive Emoji Selector Menu |
| `SUPER` + `v` | Clipboard History Management Engine |
| `SUPER` + `Escape` | Instantly Lock Workspace with Active Background |
| `SUPER` + `Shift` + `e` | Trigger Unified Power/Session Menu |
| `PrintScreen` | Capture Screen Region to **Satty** Editor |
| `ALT` + `q` | Kill/Terminate Active Application Window |
| `SUPER` + `Shift` + `q` | Force Exit Current MangoWM Layout Session |
