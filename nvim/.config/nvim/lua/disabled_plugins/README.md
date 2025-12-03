# Neovim Theme Management

This directory contains disabled theme plugins that you can easily swap to.

## How to Switch Themes

To switch from Everforest to another theme:

1. **Move the current theme to disabled_plugins/**:
   ```bash
   mv lua/plugins/everforest.lua lua/disabled_plugins/
   ```

2. **Move the desired theme from disabled_plugins/ to plugins/**:
   ```bash
   mv lua/disabled_plugins/gruvbox.lua lua/plugins/
   ```

3. **Restart Neovim** or run `:Lazy sync`

## Available Themes

- **everforest.lua** - Currently active (Everforest Dark Medium)
- **gruvbox.lua** - Gruvbox Dark Hard (disabled)

## Adding New Themes

To add a new theme:

1. Create a new file in `lua/plugins/` (e.g., `catppuccin.lua`)
2. Configure it with `priority = 1000`
3. Move old theme to `disabled_plugins/` folder
4. Restart Neovim

Only one theme should be active at a time (in the `plugins/` folder).

## Note

This folder is outside `lua/plugins/` so lazy.nvim won't auto-load these plugins.
