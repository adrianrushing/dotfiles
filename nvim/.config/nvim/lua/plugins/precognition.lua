return {
  "tris203/precognition.nvim",
  event = "VeryLazy",
  opts = {
    startVisible = false, -- Start with hints disabled (toggle with <leader>tp)
    showBlankVirtLine = true,
    highlightColor = { link = "Comment" },
    hints = {
      Caret = { text = "^", prio = 2 },
      Dollar = { text = "$", prio = 1 },
      MatchingPair = { text = "%", prio = 5 },
      Zero = { text = "0", prio = 1 },
      w = { text = "w", prio = 10 },
      b = { text = "b", prio = 9 },
      e = { text = "e", prio = 8 },
      W = { text = "W", prio = 7 },
      B = { text = "B", prio = 7 },
      E = { text = "E", prio = 7 },
    },
    gutterHints = {
      G = { text = "G", prio = 10 },
      gg = { text = "gg", prio = 9 },
      PrevParagraph = { text = "{", prio = 8 },
      NextParagraph = { text = "}", prio = 8 },
    },
    disabled_fts = {
      "startify",
      "neo-tree",
      "NvimTree",
      "Trouble",
      "neogit",
      "alpha",
    },
  },
  config = function(_, opts)
    require("precognition").setup(opts)

    -- Toggle precognition hints
    vim.keymap.set("n", "<leader>tp", function()
      require("precognition").toggle()
    end, { desc = "Toggle Precognition Hints" })
  end,
}
