return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim", -- put extension as dependency here
    },
    config = function()
      local telescope = require("telescope")

      -- Setup telescope + extensions
      telescope.setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      -- Load the extension
      telescope.load_extension("ui-select")

      -- Setup keymaps
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      -- Search including hidden files (for dotfiles)
      vim.keymap.set("n", "<leader>fh", function()
        builtin.find_files({ hidden = true })
      end, { desc = "Find files (including hidden)" })
    end,
  },
}
