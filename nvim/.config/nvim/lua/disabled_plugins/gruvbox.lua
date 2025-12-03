-- File: plugins/gruvbox.lua
-- To activate: move this file to lua/plugins/ and move everforest.lua to disabled/
return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    vim.o.background = "dark"
    vim.cmd([[colorscheme gruvbox]])
  end,
  opts = {
    contrast = "hard",
    transparent_mode = false,
  }
}
