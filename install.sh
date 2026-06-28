#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/ranib/mango-config.git"
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

echo -e "${GREEN}"
cat << "EOF"
 __  __                      _ 
|  \/  |  __ _ _ __   __ _  (_)
| |\/| | / _` | '_ \ / _` | | |
| |  | || (_| | | | | (_| | | |
|_|  |_| \__,_|_| |_|\__, | |_|
                     |___/     
EOF
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Do not run this script as root!${NC}"
   exit 1
fi

# Install base dependencies
echo -e "${BLUE}[1/8] Installing base dependencies...${NC}"
sudo pacman -S --needed --noconfirm git base-devel

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo -e "${BLUE}[2/8] Installing yay...${NC}"
    cd /tmp
    rm -rf yay # Clean up if previous attempt failed
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
else
    echo -e "${YELLOW}[2/8] yay already installed, skipping...${NC}"
fi

# Install mangowc
echo -e "${BLUE}[3/8] Installing mangowc...${NC}"
if ! pacman -Qq mangowc &> /dev/null; then
    yay -S --noconfirm mangowc
else
    echo -e "${YELLOW}mangowc already installed, skipping...${NC}"
fi

# Install SDDM
echo -e "${BLUE}[4/8] Installing SDDM...${NC}"
if ! pacman -Qq sddm &> /dev/null; then
    yay -S --noconfirm sddm
else
    echo -e "${YELLOW}SDDM already installed, skipping...${NC}"
fi

# Check for NVIDIA and install drivers
#echo -e "${BLUE}[5/8] Checking for NVIDIA GPU...${NC}"
#if lspci | grep -i nvidia &> /dev/null; then
#    echo -e "${GREEN}NVIDIA GPU detected! Installing drivers...${NC}"
#    yay -S --noconfirm nvidia-open nvidia-settings nvidia-utils
#    
#    # Enable nvidia modules
#    sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
#    sudo mkinitcpio -P
#    
#    echo -e "${GREEN}NVIDIA drivers installed and configured!${NC}"
#else
#    echo -e "${YELLOW}No NVIDIA GPU detected, skipping driver installation...${NC}"
#fi

# Clone dotfiles
echo -e "${BLUE}[6/8] Installing dotfiles...${NC}"
if [ -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}Dotfiles directory exists, backing up...${NC}"
    mv "$DOTFILES_DIR" "${DOTFILES_DIR}.backup.$(date +%s)"
fi
git clone "$REPO_URL" "$DOTFILES_DIR"

# Backup existing config and create symlinks
echo -e "${BLUE}Creating symlinks...${NC}"
mkdir -p "$CONFIG_DIR"

declare -a configs=("btop" "fastfetch" "cava" "mango" "rofi" "swaylock" "swayosd" "themes" "waybar" "yazi" "mako")

for config in "${configs[@]}"; do
    # If it's a directory and NOT a symlink, back it up
    if [ -d "$CONFIG_DIR/$config" ] && [ ! -L "$CONFIG_DIR/$config" ]; then
        echo -e "${YELLOW}Backing up existing $config config...${NC}"
        mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.backup.$(date +%s)"
    # If it's already a symlink, delete it so ln doesn't nest it
    elif [ -L "$CONFIG_DIR/$config" ]; then
        rm "$CONFIG_DIR/$config"
    fi
    ln -sf "$DOTFILES_DIR/$config" "$CONFIG_DIR/$config"
    echo -e "${GREEN}✓ Linked $config${NC}"
done

# Install required packages
echo -e "${BLUE}[7/8] Installing required packages...${NC}"
yay -S --needed --noconfirm \
    awww \
    bibata-cursor-theme \
    brightnessctl \
    curl \
    fastfetch \
    btop \
    dimland-git \
    imagemagick-git \
    waybar \
    rofi \
    rofimoji \
    cliphist \
    libnotify \
    mako \
    swaybg \
    swayosd \
    swaylock-effects-git \
    swaync \
    swayidle \
    sway-audio-idle-inhibit-git \
    slurp \
    satty \
    sox \
    nano \
    nwg-look \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    open-tv-bin \
    os-prober \
    pavucontrol \
    waypaper \
    swww \
    foot \
    pamixer \
    pulsemixer \
    grim \
    xdg-desktop-portal-wlr \
    wlr-randr \
    wlr-dpms \
    wl-clipboard \
    wl-clip-persist \
    wlsunset \
    wlogout \
    xfce-polkit \
    zen-browser-bin \
    zoxide

# Remove firefox gracefully if installed
if pacman -Qq firefox &> /dev/null; then
    echo -e "${BLUE}Removing Firefox...${NC}"
    sudo pacman -Rns --noconfirm firefox
fi

# Make fastfetch look like Archcraft
echo -e "${BLUE}Configuring Fastfetch...${NC}"
cd /tmp
rm -rf fastfetch-config
git clone https://github.com/ExploitCraft/fastfetch-config.git
mkdir -p ~/.config/fastfetch/images
cp -f fastfetch-config/config.jsonc ~/.config/fastfetch/config.jsonc
cd ~

# Install starship for terminal    
echo -e "${BLUE}Installing Starship prompt...${NC}"
curl -sS https://starship.rs/install.sh | sh -s -- -y
mkdir -p ~/.config
touch ~/.config/starship.toml
starship preset pastel-powerline -o ~/.config/starship.toml

# Edit grub (Note: Manually edit /etc/default/grub if you need adjustments)
echo -e "${BLUE}Updating GRUB configuration...${NC}"
sudo grub-mkconfig -o /boot/grub/grub.cfg
 
# Make scripts executable
echo -e "${BLUE}[8/8] Making scripts executable...${NC}"
if [ -d "$CONFIG_DIR/mango/rofi" ]; then
    chmod +x "$CONFIG_DIR/mango/rofi"/*.sh
    echo -e "${GREEN}✓ Rofi scripts are now executable${NC}"
fi

if [ -d "$CONFIG_DIR/mango/scripts" ]; then
    chmod +x "$CONFIG_DIR/mango/scripts"/*.sh
    echo -e "${GREEN}✓ Core scripts are now executable${NC}"
else
    echo -e "${YELLOW}Warning: scripts directory not found${NC}"
fi

# Enable SDDM
echo -e "${BLUE}Enabling SDDM...${NC}"
sudo systemctl enable sddm

echo -e "\n${GREEN}"
cat << "EOF"
                                              
    Installation Complete!
EOF
echo -e "${NC}"
echo -e "${YELLOW}System will reboot in 5 seconds...${NC}"
echo -e "${YELLOW}Press Ctrl+C to cancel reboot${NC}\n"

sleep 5
sudo systemctl reboot
