return {
  "sainnhe/everforest",
  lazy = false,
  priority = 10000,  -- Highest priority - loads before everything
  config = function()
    -- Configure everforest
    vim.g.everforest_background = 'medium'
    vim.g.everforest_better_performance = 1
    vim.g.everforest_enable_italic = 1
    
    -- Load the colorscheme
    vim.cmd([[colorscheme everforest]])
  end,
}
