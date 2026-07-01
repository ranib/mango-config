#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com"
CONFIG_DIR="$HOME/.config"

echo -e "${GREEN}"
cat << "EOF"
 __  __                                

|  \/  |  __ _  _ __    __ _   ___     
| |\/| | / _` || '_ \  / _` | / _ \    
| |  | || (_| || | | || (_| || (_) |   
|_|  |_| \__,_||_| |_| \__, | \___/    
                       |___/           
EOF
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Do not run this script as root!${NC}"
   exit 1
fi

# Clone or move dotfiles straight into the Mango directory first to access local scripts
echo -e "${BLUE}[1/8] Organizing Mango configuration directory...${NC}"

# If an old mango folder exists, back it up safely
if [ -d "$CONFIG_DIR/mango" ]; then
    echo -e "${YELLOW}Existing mango config folder found, creating backup...${NC}"
    mv "$CONFIG_DIR/mango" "$CONFIG_DIR/mango.backup.$(date +%s)"
fi

# Clone your entire git repo directly to ~/.config/mango
echo -e "${BLUE}Cloning your repository cleanly into $CONFIG_DIR/mango...${NC}"
git clone "$REPO_URL" "$CONFIG_DIR/mango"

# Key Initialization Check
echo -e "${BLUE}[2/8] Running key signature adjustments...${NC}"
REPO_KEYS_SCRIPT="$CONFIG_DIR/mango/scripts/fix-keys"

if [ -f "$REPO_KEYS_SCRIPT" ]; then
    echo -e "${GREEN}Running your repository-hosted key-fix script...${NC}"
    bash "$REPO_KEYS_SCRIPT"
else
    echo -e "${YELLOW}Warning: fix-keys not found in repo. Attempting vanilla key refresh instead...${NC}"
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
fi

# Install base dependencies
echo -e "${BLUE}[3/8] Installing base compiler dependencies...${NC}"
sudo pacman -S --needed --noconfirm git base-devel

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo -e "${BLUE}[4/8] Installing yay AUR helper...${NC}"
    cd /tmp
    rm -rf yay
    git clone https://archlinux.org
    cd yay
    makepkg -si --noconfirm
    cd ~
else
    echo -e "${YELLOW}yay already installed, skipping...${NC}"
fi

# Install mangowc
echo -e "${BLUE}[5/8] Installing MangoWM compositor from AUR...${NC}"
if ! pacman -Qq mangowc &> /dev/null && ! pacman -Qq mangowm-git &> /dev/null; then
    yay -S --noconfirm mangowm-git || yay -S --noconfirm mangowc
else
    echo -e "${YELLOW}MangoWM already installed, skipping...${NC}"
fi

# Install SDDM + SilentSDDM Theme Runtime Dependencies
echo -e "${BLUE}[6/8] Installing SDDM, SilentSDDM, and Qt6 graphics layers...${NC}"
if ! pacman -Qq sddm &> /dev/null; then
    yay -S --noconfirm sddm
else
    echo -e "${YELLOW}SDDM core already installed...${NC}"
fi

# Explicitly pull runtime dependencies and the SilentSDDM Git engine from AUR
sudo pacman -S --needed --noconfirm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg qt6-imageformats
yay -S --noconfirm sddm-silent-theme-git

# Deploy safe system configurations to activate the SilentSDDM theme cleanly
echo -e "${BLUE}Injecting SilentSDDM theme targets into system architecture...${NC}"
sudo mkdir -p /etc/sddm.conf.d
cat << 'EOF' | sudo tee /etc/sddm.conf.d/theme.conf > /dev/null
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
EOF

# Create symlinks out to global folders ONLY for global standalone tools
echo -e "${BLUE}[7/8] Linking global terminal and system utility layouts...${NC}"
mkdir -p "$CONFIG_DIR"

# Global system tools look for their setups at the root of ~/.config/
declare -a global_configs=("btop" "fastfetch" "foot" "swayidle" "wlogout")

for config in "${global_configs[@]}"; do
    if [ -d "$CONFIG_DIR/mango/$config" ]; then
        if [ -d "$CONFIG_DIR/$config" ] && [ ! -L "$CONFIG_DIR/$config" ]; then
            mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.backup.$(date +%s)"
        elif [ -L "$CONFIG_DIR/$config" ]; then
            rm "$CONFIG_DIR/$config"
        fi
        ln -sf "$CONFIG_DIR/mango/$config" "$CONFIG_DIR/$config"
        echo -e "${GREEN}✓ Globally linked $config${NC}"
    fi
done

# Install required packages (Includes Core Essentials, Waybar, Audio, and Video Toolkits)
echo -e "${BLUE}[8/8] Installing required system packages...${NC}"
yay -S --needed --noconfirm \
    awww \
    bibata-cursor-theme \
    brightnessctl \
    curl \
    fastfetch \
    btop \
    imagemagick-git \
    waybar \
    rofi \
    rofimoji \
    cliphist \
    libnotify \
    swayosd \
    veila-bin \
    swaync \
    swayidle \
    slurp \
    satty \
    nano \
    nwg-look \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    os-prober \
    pavucontrol \
    waypaper \
    swww \
    foot \
    pamixer \
    grim \
    xdg-desktop-portal-wlr \
    wl-clipboard \
    wlsunset \
    wlogout \
    xfce-polkit \
    zen-browser-bin \
    zoxide \
    thunar \
    yazi \
    gvfs \
    gvfs-mtp \
    tumbler \
    pipewire-pulse \
    wireplumber \
    mpv \
    network-manager-applet \
    bluez \
    bluez-utils \
    blueman \
    qt5-wayland \
    qt6-wayland \
    ffmpeg

# Remove firefox gracefully if installed
if pacman -Qq firefox &> /dev/null; then
    echo -e "${BLUE}Removing Firefox...${NC}"
    sudo pacman -Rns --noconfirm firefox
fi

# Make fastfetch look like Archcraft using your native, Foot-optimized configuration
echo -e "${BLUE}Configuring Fastfetch for Foot terminal environment...${NC}"
mkdir -p "$CONFIG_DIR/fastfetch"
if [ -f "$CONFIG_DIR/mango/fastfetch/config.jsonc" ]; then
    cp -f "$CONFIG_DIR/mango/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc"
    echo -e "${GREEN}✓ Fastfetch profile deployed from repository assets${NC}"
else
    fastfetch --gen-config jsonc
fi

# Install starship for terminal    
echo -e "${BLUE}Installing Starship prompt...${NC}"
curl -sS https://starship.rs | sh -s -- -y

# Generate the Pastel Powerline configuration natively
echo -e "${BLUE}Applying Pastel Powerline preset...${NC}"
starship preset pastel-powerline -o "$HOME/.config/starship.toml"
echo -e "${GREEN}✓ Starship initialized with Pastel Powerline!${NC}"

# Automate GRUB edits
echo -e "${BLUE}Configuring GRUB settings...${NC}"
GRUB_FILE="/etc/default/grub"

if [ -f "$GRUB_FILE" ]; then
    sudo sed -i 's/^#\?GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' "$GRUB_FILE"
    sudo sed -i 's/^#\?GRUB_GFXMODE=.*/GRUB_GFXMODE=1024x768x32/' "$GRUB_FILE"

    if grep -q "GRUB_DISABLE_OS_PROBER" "$GRUB_FILE"; then
        sudo sed -i 's/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_FILE"
    else
        echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a "$GRUB_FILE" > /dev/null
    fi

    echo -e "${GREEN}GRUB configured. Updating main config layout...${NC}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo -e "${RED}Warning: /etc/default/grub not found! Skipping GRUB edits.${NC}"
fi
 
# Make scripts executable
echo -e "${BLUE}Enforcing script permissions...${NC}"
if [ -d "$CONFIG_DIR/mango/rofi" ]; then
    chmod +x "$CONFIG_DIR/mango/rofi"/*.sh
    echo -e "${GREEN}✓ Rofi scripts are now executable${NC}"
fi

if [ -d "$CONFIG_DIR/mango/scripts" ]; then
    chmod +x "$CONFIG_DIR/mango/scripts"/*
    echo -e "${GREEN}✓ All core utility, fix-keys, and autostart scripts are now executable${NC}"
else
    echo -e "${YELLOW}Warning: scripts directory not found${NC}"
fi

# Enable System Core Daemons
echo -e "${BLUE}Enabling Bluetooth background service...${NC}"
sudo systemctl enable --now bluetooth

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
