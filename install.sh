#!/bin/bash

# Create the target directory if it does not exist
mkdir -p ~/post-install-scripts

cp -r ~/Linux-Post-Installation/ ~/post-install-scripts

chmod +x ~/post-install-scripts/scripts/setup.sh

# Run the setup script
bash ~/post-install-scripts/scripts/setup.sh