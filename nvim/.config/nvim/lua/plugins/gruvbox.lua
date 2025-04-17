-- File: plugins/gruvbox.lua
return {
  "ellisonleao/gruvbox.nvim",  -- Plugin name
  priority = 1000,             -- Plugin priority
  config = function()
    vim.o.background = "dark"  -- Set the background to dark or light
    vim.cmd([[colorscheme gruvbox]])  -- Apply the color scheme
  end,
  opts = {
    contrast = "hard",  -- Set contrast level: 'hard', 'medium', or 'soft'
    transparent_mode = false,  -- Optionally set transparent background
  }
}

