return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local quarto = require("quarto")
      quarto.setup({
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          chunks = "curly",
          languages = { "python", "bash", "lua", "html" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      })

      -- Keybindings for Quarto
      vim.keymap.set("n", "<leader>qp", quarto.quartoPreview, { desc = "Quarto Preview", silent = true })
      vim.keymap.set("n", "<leader>qq", quarto.quartoClosePreview, { desc = "Quarto Close Preview", silent = true })

      -- Additional useful Quarto commands
      vim.keymap.set("n", "<leader>qr", function()
        vim.cmd("QuartoSend")
      end, { desc = "Quarto Render", silent = true })
    end,
  },
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
  },
}
