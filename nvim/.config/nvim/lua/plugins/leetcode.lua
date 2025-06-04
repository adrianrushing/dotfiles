return {
  "kawre/leetcode.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter", -- Ensure nvim-treesitter is included
  },
  build = function()
    -- Ensure Treesitter is properly configured
    require("nvim-treesitter.configs").setup({})
    vim.cmd("TSUpdate html")
  end,
  opts = {
    lang = "python3", -- Change "cpp" to your preferred language
  },
}
