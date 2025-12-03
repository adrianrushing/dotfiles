#!/bin/bash
# Clean and install Everforest theme

echo "Removing gruvbox from lazy.nvim cache..."
rm -rf ~/.local/share/nvim/lazy/gruvbox.nvim

echo "Starting Neovim to sync plugins..."
echo "Lazy.nvim will auto-install Everforest"
echo "After Neovim opens, wait for installation to complete or run :Lazy sync"
