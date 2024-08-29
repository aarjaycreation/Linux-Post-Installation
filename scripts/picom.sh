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
        exit 1
    fi
}

# Function to install dependencies using the detected package manager
install_dependencies() {
    local pkg_mgr="$1"
    
    case $pkg_mgr in
        apt)
            sudo apt update
            sudo apt install -y \
                libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev \
                libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev \
                libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev \
                libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev \
                libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build \
                uthash-dev build-essential
            ;;
        dnf)
            sudo dnf install -y \
                libconfig-devel dbus-devel mesa-libEGL-devel libev-devel mesa-libGL-devel \
                libepoxy-devel pcre2-devel pixman-devel libX11-xcb-devel libxcb-devel \
                libxcb-composite-devel libxcb-damage-devel libxcb-dpms-devel libxcb-glx-devel \
                libxcb-image-devel libxcb-present-devel libxcb-randr-devel libxcb-render-devel \
                libxcb-renderutil-devel libxcb-shape-devel libxcb-util-devel libxcb-xfixes-devel \
                libXext-devel meson ninja-build uthash-devel make gcc gcc-c++
            ;;
        pacman)
            sudo pacman -Syu --noconfirm \
                libconfig dbus-glib mesa libev libglvnd libepoxy pcre2 pixman libx11 libxcb libxext \
                meson ninja uthash base-devel
            ;;
        zypper)
            sudo zypper install -y \
                libconfig-devel dbus-1-devel libEGL1-devel libev-devel libGL-devel libepoxy-devel \
                pcre2-devel pixman-devel libX11-devel libxcb-devel libxcb-composite-devel \
                libxcb-damage0-devel libxcb-dpms-devel libxcb-glx-devel libxcb-image0-devel \
                libxcb-present-devel libxcb-randr0-devel libxcb-render0-devel libxcb-render-util0-devel \
                libxcb-shape0-devel libxcb-util-devel libxcb-xfixes0-devel libXext-devel meson ninja \
                uthash-devel gcc-c++ make
            ;;
    esac
}

# Check if picom is already installed
if picom --version >/dev/null 2>&1; then
    exit 0
fi

# Detect the package manager and install dependencies
detect_package_manager
install_dependencies "$pkg_mgr"

# Clone Picom repository and build using Meson/Ninja
git clone https://github.com/FT-Labs/picom ~/post-install-scripts/scripts/picom
cd ~/post-install-scripts/scripts/picom
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install

