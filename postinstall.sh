#!/bin/bash

# Color definitions
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 1>&2
   exit 1
fi

echo -e "${YELLOW}Running script...${NC}"

# Define destination and create directories
DESTINATION="/home/$SUDO_USER/.config"
mkdir -p "$DESTINATION"
mkdir -p "/home/$SUDO_USER/scripts"

echo -e "${GREEN}---------------------------------------------------"
echo -e "            Installing dependencies"
echo -e "---------------------------------------------------${NC}"

cd "/home/$SUDO_USER/Linux-Post-Installation/scripts" || exit

# Making scripts executable
chmod +x install_packages install_nala picom
./install_packages

echo -e "${GREEN}---------------------------------------------------"
echo -e "       Moving dotfiles to correct location"
echo -e "---------------------------------------------------${NC}"

cd "/home/$SUDO_USER/Linux-Post-Installation/dotfiles" || exit

cp -r alacritty backgrounds fastfetch kitty picom rofi suckless "$DESTINATION/"

echo -e "${GREEN}---------------------------------------------------"
echo -e "    Moving Home dir files to correct location"
echo -e "---------------------------------------------------${NC}"

cp .bashrc "/home/$SUDO_USER/"
cp -r .local "/home/$SUDO_USER/"
cp -r scripts "/home/$SUDO_USER/"
cp .xinitrc "/home/$SUDO_USER/"

echo -e "${GREEN}---------------------------------------------------"
echo -e "            Fixing Home dir permissions"
echo -e "---------------------------------------------------${NC}"

chown -R "$SUDO_USER":"$SUDO_USER" "/home/$SUDO_USER/.config"
chown -R "$SUDO_USER":"$SUDO_USER" "/home/$SUDO_USER/scripts"
chown "$SUDO_USER":"$SUDO_USER" "/home/$SUDO_USER/.bashrc"
chown -R "$SUDO_USER":"$SUDO_USER" "/home/$SUDO_USER/.local"
chown "$SUDO_USER":"$SUDO_USER" "/home/$SUDO_USER/.xinitrc"

echo -e "${GREEN}---------------------------------------------------"
echo -e "                 Updating Timezone"
echo -e "---------------------------------------------------${NC}"

if command -v apt > /dev/null 2>&1; then
    dpkg-reconfigure tzdata
else
    echo -e "${YELLOW}Unable to detect APT. Skipping timezone configuration.${NC}"
fi

echo -e "${GREEN}---------------------------------------------------"
echo -e "            Building DWM and SLStatus"
echo -e "---------------------------------------------------${NC}"

cd "/home/$SUDO_USER/.config/suckless/dwm" || exit
make clean install || echo -e "${RED}DWM build failed.${NC}"
cd "/home/$SUDO_USER/.config/suckless/slstatus" || exit
make clean install || echo -e "${RED}SLStatus build failed.${NC}"

echo -e "${GREEN}---------------------------------------------------${NC}"
echo -e "${GREEN}    Do you want to start Linux Toolbox? (y/n)"
echo -e "---------------------------------------------------${NC}"

read -r response

if [[ "$response" == "y" || "$response" == "Y" ]]; then
    echo -e "${YELLOW}Press Q to exit ${NC}"
    echo -e "${GREEN}Launching in...${NC}"

    for i in {5..1}; do
        echo -e "${YELLOW}$i..${NC}"
        sleep 1
    done

    curl -fsSL https://christitus.com/linux | sh
else
    echo -e "${GREEN}Skipping...${NC}"
fi

echo -e "${GREEN}---------------------------------------------------"
echo -e "     Script finished. Reboot is recommended"
echo -e "---------------------------------------------------${NC}"
echo -e "${GREEN}    Do you want to restart the system now? (y/n)"
echo -e "---------------------------------------------------${NC}"

read -r response

if [[ "$response" == "y" || "$response" == "Y" ]]; then
    echo -e "${GREEN}Restarting the system...${NC}"
    reboot
else
    echo -e "${GREEN}Restart skipped. Please remember to restart your system later.${NC}"
fi
