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
      { "<leader>c", group = "Code" },
      { "<leader>d", group = "Debug/Delete" },
      { "<leader>f", group = "Find/File" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Hunk" },
      { "<leader>m", group = "Molten" },
      { "<leader>q", group = "Quarto/Session" },
      { "<leader>r", group = "REPL" },
      { "<leader>s", group = "Search/Send" },
      { "<leader>t", group = "Toggle" },
      { "<leader>w", group = "Workspace" },
      { "<leader>x", group = "Diagnostics" },
    },
  },
}
