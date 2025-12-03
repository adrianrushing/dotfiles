return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  opts = {
    -- Maximum number of times you can press a key before it's disabled
    max_count = 4,
    
    -- Enable hardtime by default
    enabled = true,
    
    -- Disable arrow keys and mouse
    disable_mouse = false,
    
    -- Show hints as floating notifications
    hint = true,
    
    -- Show notification when you hit max_count
    notification = true,
    
    -- Allow different keys in a row (recommended)
    allow_different_key = true,
    
    -- Restricted keys - blocks inefficient patterns
    restriction_mode = "block",
    
    -- Notification display time (milliseconds)
    resetting_keys = {
      ["0"] = { "n", "x" },
      ["1"] = { "n", "x" },
      ["^"] = { "n", "x" },
      ["$"] = { "n", "x" },
      ["w"] = { "n", "x" },
      ["W"] = { "n", "x" },
      ["b"] = { "n", "x" },
      ["B"] = { "n", "x" },
      ["e"] = { "n", "x" },
      ["E"] = { "n", "x" },
    },
    
    -- Keys that will be restricted
    restricted_keys = {
      ["h"] = { "n", "x" },
      ["j"] = { "n", "x" },
      ["k"] = { "n", "x" },
      ["l"] = { "n", "x" },
      ["-"] = { "n", "x" },
      ["+"] = { "n", "x" },
      ["gj"] = { "n", "x" },
      ["gk"] = { "n", "x" },
      ["<CR>"] = { "n", "x" },
      ["<C-M>"] = { "n", "x" },
      ["<C-N>"] = { "n", "x" },
      ["<C-P>"] = { "n", "x" },
    },
    
    -- Disabled keys - completely blocked
    disabled_keys = {
      ["<Up>"] = { "", "i", "n", "v" },
      ["<Down>"] = { "", "i", "n", "v" },
      ["<Left>"] = { "", "i", "n", "v" },
      ["<Right>"] = { "", "i", "n", "v" },
    },
    
    -- Filetypes to disable hardtime
    disabled_filetypes = {
      "qf",
      "netrw",
      "NvimTree",
      "neo-tree",
      "lazy",
      "mason",
      "oil",
      "Trouble",
      "neogit",
      "alpha",
      "help",
    },
    
    -- Custom hints that appear as popups
    hints = {
      ["k%^"] = {
        message = function()
          return "Use - instead of k^" .. " [count]"
        end,
        length = 2,
      },
      ["j%$"] = {
        message = function()
          return "Use + instead of j$" .. " [count]"
        end,
        length = 2,
      },
    },
  },
  config = function(_, opts)
    require("hardtime").setup(opts)
    
    -- Keybinding to toggle hardtime
    vim.keymap.set("n", "<leader>th", "<cmd>Hardtime toggle<CR>", { desc = "Toggle Hardtime" })
    
    -- Show hardtime status
    vim.keymap.set("n", "<leader>tH", function()
      vim.cmd("Hardtime report")
    end, { desc = "Hardtime Report" })
  end,
}
