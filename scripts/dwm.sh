#!/bin/bash

# Function to detect the package manager
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        pkg_mgr="apt"
    elif command -v dnf >/dev/null 2>&1; then
        pkg_mgr="dnf"
    elif command -v pacman >/dev/null 2>&1; then
        pkg_mgr="pacman"
    elif command -v zypper >/dev/null 2>&1; then
        pkg_mgr="zypper"
    else
        echo "No supported package manager found."
        exit 1
    fi
}

# Function to install packages using the detected package manager
install_packages() {
    local pkgs=("$@")
    local missing_pkgs=()

    case $pkg_mgr in
        apt)
            for pkg in "${pkgs[@]}"; do
                if ! dpkg -l | grep -q " $pkg "; then
                    missing_pkgs+=("$pkg")
                fi
            done
            if [ ${#missing_pkgs[@]} -gt 0 ]; then
                sudo apt update
                sudo apt install -y "${missing_pkgs[@]}"
            fi
            ;;
        dnf)
            for pkg in "${pkgs[@]}"; do
                if ! rpm -q "$pkg" >/dev/null 2>&1; then
                    missing_pkgs+=("$pkg")
                fi
            done
            if [ ${#missing_pkgs[@]} -gt 0 ]; then
                sudo dnf install -y "${missing_pkgs[@]}"
            fi
            ;;
        pacman)
            for pkg in "${pkgs[@]}"; do
                if ! pacman -Qq | grep -q "^$pkg$"; then
                    missing_pkgs+=("$pkg")
                fi
            done
            if [ ${#missing_pkgs[@]} -gt 0 ]; then
                sudo pacman -Syu --noconfirm "${missing_pkgs[@]}"
            fi
            ;;
        zypper)
            for pkg in "${pkgs[@]}"; do
                if ! rpm -q "$pkg" >/dev/null 2>&1; then
                    missing_pkgs+=("$pkg")
                fi
            done
            if [ ${#missing_pkgs[@]} -gt 0 ]; then
                sudo zypper install -y "${missing_pkgs[@]}"
            fi
            ;;
    esac
}

# Function to check and rename ~/.config/suckless if it exists
check_and_rename_suckless_dir() {
    local suckless_dir="$HOME/.config/suckless"
    local backup_dir="$HOME/.config/suckless.orig"

    if [ -d "$suckless_dir" ]; then
        mv "$suckless_dir" "$backup_dir"
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi
}

# Function to create ~/.xinitrc file
create_xinitrc() {
    echo "exec dwm" > ~/.xinitrc
    chmod +x ~/.xinitrc
}

# Function to add startx to ~/.bashrc
add_startx_to_bashrc() {
    local bashrc_file="$HOME/.bashrc"
    if [ -f "$bashrc_file" ]; then
        if ! grep -q "startx" "$bashrc_file"; then
            echo "startx" >> "$bashrc_file"
        fi
    else
        echo "No ~/.bashrc file found."
    fi
}

# Prompt user for whether to install a login manager
read -p "Do you want to install a login manager (sddm)? (y/n): " use_login_manager

# Detect the package manager and install dependencies
detect_package_manager

# Define common packages
packages=(
    "xorg-dev"
    "sxhkd"
    "firefox-esr"
    "tilix"
    "kitty"
    "flameshot"
    "ranger"
    "thunar"
)

# Function to read common packages from a file
read_common_packages() {
    local common_file="$1"
    if [ -f "$common_file" ]; then
        packages+=( $(< "$common_file") )
    else
        echo "Common packages file not found: $common_file"
        exit 1
    fi
}

# Read common packages from file
read_common_packages "$HOME/bookworm-scripts/install_scripts/common_packages.txt"

# Install main packages
install_packages "${packages[@]}"

# Install and configure login manager if required
if [[ "$use_login_manager" =~ ^[Yy]$ ]]; then
    case $pkg_mgr in
        apt)
            sudo apt install -y sddm
            ;;
        dnf)
            sudo dnf install -y sddm
            ;;
        pacman)
            sudo pacman -Syu --noconfirm sddm
            ;;
        zypper)
            sudo zypper install -y sddm
            ;;
    esac
    # Enable sddm service
    sudo systemctl enable sddm
else
    # Create ~/.xinitrc for startx
    create_xinitrc
    # Add startx to ~/.bashrc if it exists
    add_startx_to_bashrc
fi

# Enable system services
case $pkg_mgr in
    apt|dnf|pacman|zypper)
        sudo systemctl enable avahi-daemon
        sudo systemctl enable acpid
        ;;
esac

# Update user directories
xdg-user-dirs-update
mkdir -p ~/Screenshots/

# Ensure /usr/share/xsessions directory exists
if [ ! -d /usr/share/xsessions ]; then
    sudo mkdir -p /usr/share/xsessions
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# Write dwm.desktop file only if a login manager is used
if [[ "$use_login_manager" =~ ^[Yy]$ ]]; then
    temp_file="./temp"
    
    # Create directory for temp file if it doesn't exist
    temp_dir=$(dirname "$temp_file")
    mkdir -p "$temp_dir"
    
    # Write the dwm.desktop file
    cat > "$temp_file" << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
EOF
    sudo cp "$temp_file" /usr/share/xsessions/dwm.desktop
    rm "$temp_file"
fi

# Clone or check existing jag_dots repository
SCRIPT_DIR=~/bookworm-scripts
REPO_URL=https://github.com/drewgrif/jag_dots.git

if [ -d "$SCRIPT_DIR/jag_dots" ]; then
    :
else
    git clone "$REPO_URL" "$SCRIPT_DIR/jag_dots"
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# Copy configuration files
cp -r ~/bookworm-scripts/jag_dots/scripts/ ~
cp -r ~/bookworm-scripts/jag_dots/.config/dunst/ ~/.config/
cp -r ~/bookworm-scripts/jag_dots/.config/kitty/ ~/.config/
cp -r ~/bookworm-scripts/jag_dots/.config/rofi/ ~/.config/
cp -r ~/bookworm-scripts/jag_dots/.config/picom/ ~/.config/
cp -r ~/bookworm-scripts/jag_dots/.config/backgrounds/ ~/.config/

# Move autostart script
mkdir -p ~/.local/share/dwm
cp -r ~/bookworm-scripts/jag_dots/.local/share/dwm/autostart.sh ~/.local/share/dwm/
chmod +x ~/.local/share/dwm/autostart.sh

# Move patched dwm, slstatus, and st
cp -r ~/bookworm-scripts/jag_dots/.config/suckless/ ~/.config/

# Install custom dwm, slstatus, and st
install_from_source() {
    local repo_path="$1"
    cd "$repo_path" || exit
    make
    sudo make clean install
}

install_from_source "~/.config/suckless/dwm"
install_from_source "~/.config/suckless/slstatus"
install_from_source "~/.config/suckless/st"