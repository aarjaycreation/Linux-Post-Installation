#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

logo () {
    echo -e "\e[1;32m
------------------------------
-- Post Installation Script --
------------------------------
\e[0m"
}

run_script () {
    clear
    logo
    echo -e "\e[1;32m Installing $1... \e[0m"
    bash ~/post-install-scripts/scripts/$1.sh || { echo "$1 installation failed"; exit 1; }
}

run_script "dependencies"
run_script "picom"
run_script "dwm"
run_script "move_files"

clear

echo -e "\e[1;32m Done! \e[0m"

