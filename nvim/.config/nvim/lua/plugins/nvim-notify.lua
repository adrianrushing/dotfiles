return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local notify = require("notify")
    
    notify.setup({
      -- Animation style
      stages = "fade_in_slide_out",
      
      -- Timeout for notifications (milliseconds)
      timeout = 3000,
      
      -- Background colour
      background_colour = "#000000",
      
      -- Icons
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },
      
      -- Notification positioning
      top_down = true,
      
      -- Minimum width
      minimum_width = 40,
      
      -- Maximum width (increased for full messages)
      max_width = 80,
      
      -- Max height
      max_height = 10,
      
      -- Render style - "default" supports text wrapping better
      render = "default",
      
      -- Level of notifications to show
      level = vim.log.levels.INFO,
    })
    
    -- Set as default notification handler
    vim.notify = notify
    
    -- Keybinding to dismiss all notifications
    vim.keymap.set("n", "<leader>tn", function()
      require("notify").dismiss({ silent = true, pending = true })
    end, { desc = "Dismiss Notifications" })
    
    -- Keybinding to show notification history
    vim.keymap.set("n", "<leader>tN", "<cmd>Telescope notify<cr>", { desc = "Notification History" })
  end,
}
