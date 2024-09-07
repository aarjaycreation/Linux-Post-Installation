#!/bin/bash

GREEN="\033[1;32m"
NC="\033[0m"

DESTINATION="$HOME/.config"

sudo mkdir -p "$DESTINATION"
sudo mkdir -p $HOME/scripts

cd "$HOME/Linux-Post-Installation/dotfiles"

echo -e "${GREEN}============================================"
echo -e "${GREEN}     Moving dotfiles to correct location"
echo -e "${GREEN}============================================${NC}"

sudo cp -r alacritty "$DESTINATION/"
sudo cp -r backgrounds "$DESTINATION/"
sudo cp -r fastfetch "$DESTINATION/"
sudo cp -r kitty "$DESTINATION/"
sudo cp -r picom "$DESTINATION/"
sudo cp -r rofi "$DESTINATION/"
sudo cp -r suckless "$DESTINATION/"

echo -e "${GREEN}============================================"
echo -e "${GREEN} Moving Home dir files to correct location"
echo -e "${GREEN}============================================${NC}"

sudo cp .bashrc "$HOME/"
sudo cp -r .local "$HOME/"
sudo cp -r scripts "$HOME/"
sudo cp .xinitrc "$HOME/"

echo -e "${GREEN}============================================"
echo -e "${GREEN}        Fixing Home dir permissions"
echo -e "${GREEN}============================================${NC}"

sudo chown -R "$USER":"$USER" "$HOME/.config"
sudo chown -R "$USER":"$USER" "$HOME/scripts"
sudo chown "$USER":"$USER" "$HOME/.bashrc"
sudo chown -R "$USER":"$USER" "$HOME/.local"
sudo chown "$USER":"$USER" "$HOME/.xinitrc"

echo -e "${GREEN}============================================"
echo -e "${GREEN}               Fixing Timezone"
echo -e "${GREEN}============================================${NC}"

sudo dpkg-reconfigure tzdata

echo -e "${GREEN}============================================"
echo -e "${GREEN}          Building DWM and SLStatus"
echo -e "${GREEN}============================================${NC}"

# make sure our .bashrc is sourced and updated
source "$HOME/.bashrc" 

#make install alias
mi

clear

echo -e "${GREEN}============================================"
echo -e "${GREEN}   Script finished. Reboot is recommended"
echo -e "${GREEN}============================================${NC}"

echo -e "${GREEN}============================================"
echo -e "${GREEN}   Do you want to restart the system now? (y/n)"
echo -e "${GREEN}============================================${NC}"

read -p "Restart now? [y/n]: " response

if [[ "$response" == "y" || "$response" == "Y" ]]; then
    echo -e "${GREEN}Restarting the system...${NC}"
    sudo reboot
else
    echo -e "${GREEN}Restart skipped. Please remember to restart your system later.${NC}"
fi