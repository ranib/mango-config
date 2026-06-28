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

# Fruitbang Key Initialization Fix
echo -e "${BLUE}Initializing Fruitbang pacman keys...${NC}"
FIX_KEYS_SCRIPT="$HOME/Scripts/fix-keys"
if [ -f "$FIX_KEYS_SCRIPT" ]; then
    echo -e "${GREEN}Running key-fix script at $FIX_KEYS_SCRIPT...${NC}"
    bash "$FIX_KEYS_SCRIPT"
else
    echo -e "${YELLOW}Warning: $FIX_KEYS_SCRIPT not found. Attempting base key refresh instead...${NC}"
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
fi

# Install base dependencies
echo -e "${BLUE}[1/8] Installing base dependencies...${NC}"
sudo pacman -S --needed --noconfirm git base-devel

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo -e "${BLUE}[2/8] Installing yay...${NC}"
    cd /tmp
    rm -rf yay
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
    if [ -d "$CONFIG_DIR/$config" ] && [ ! -L "$CONFIG_DIR/$config" ]; then
        echo -e "${YELLOW}Backing up existing $config config...${NC}"
        mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.backup.$(date +%s)"
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

# Make fastfetch look like Archcraft but force the Arch ASCII Logo
echo -e "${BLUE}Configuring Fastfetch...${NC}"
cd /tmp
rm -rf fastfetch-config
git clone https://github.com/ExploitCraft/fastfetch-config.git
mkdir -p ~/.config/fastfetch/images
cp -f fastfetch-config/config.jsonc ~/.config/fastfetch/config.jsonc

# Automatically replace the custom logo source with the official Arch ASCII logo
sed -i 's/"source":.*/"source": "arch",/' ~/.config/fastfetch/config.jsonc
sed -i 's/"type":.*/"type": "auto",/' ~/.config/fastfetch/config.jsonc

cd ~

# Install starship for terminal    
echo -e "${BLUE}Installing Starship prompt...${NC}"
curl -sS https://starship.rs/install.sh | sh -s -- -y
mkdir -p ~/.config
touch ~/.config/starship.toml
starship preset pastel-powerline -o ~/.config/starship.toml

# Automate GRUB edits
echo -e "${BLUE}Configuring GRUB settings...${NC}"
GRUB_FILE="/etc/default/grub"

if [ -f "$GRUB_FILE" ]; then
    # 1. Update GRUB_TIMEOUT
    sudo sed -i 's/^#\?GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' "$GRUB_FILE"

    # 2. Update GRUB_GFXMODE
    sudo sed -i 's/^#\?GRUB_GFXMODE=.*/GRUB_GFXMODE=1024x768x32/' "$GRUB_FILE"

    # 3. Update GRUB_DISABLE_OS_PROBER (or append it if completely missing)
    if grep -q "GRUB_DISABLE_OS_PROBER" "$GRUB_FILE"; then
        sudo sed -i 's/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_FILE"
    else
        echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a "$GRUB_FILE" > /dev/null
    fi

    # Regenerate main GRUB layout
    echo -e "${GREEN}GRUB configured. Updating main config layout...${NC}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo -e "${RED}Warning: /etc/default/grub not found! Skipping GRUB edits.${NC}"
fi
 
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
