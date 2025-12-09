#!/bin/sh
echo "Starting rasbian_setup.sh"
sudo apt update
sudo apt -y full-upgrade
sudo apt -y install powerline git neovim fzf ripgrep fd-find
