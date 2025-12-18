return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    preset = "modern",
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    spec = {
      { "<leader>c", group = "LSP | Trouble" },
      { "<leader>d", group = "LSP" },
      { "<leader>f", group = "Telescope" },
      { "<leader>g", group = "Neogit | Gitsigns" },
      { "<leader>h", group = "Gitsigns" },
      { "<leader>m", group = "Mark | Molten" },
      { "<leader>q", group = "Quarto | Persistence" },
      { "<leader>r", group = "Iron | LSP" },
      { "<leader>s", group = "Iron | Telescope" },
      { "<leader>t", group = "Toggle" },
      { "<leader>w", group = "LSP" },
      { "<leader>x", group = "Trouble" },
    },
  },
}

