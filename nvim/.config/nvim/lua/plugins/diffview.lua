return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File History" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repo History" },
    { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close Diffview" },
  },
  config = function()
    require("diffview").setup({
      diff_binaries = false, -- Show diffs for binaries
      enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
      git_cmd = { "git" }, -- The git executable followed by default args.
      use_icons = true, -- Requires nvim-web-devicons
      show_help_hints = true, -- Show hints for how to open the help panel
      watch_index = true, -- Update views and index buffers when the git index changes.
      icons = { -- Only applies when use_icons is true.
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      view = {
        -- Configure the layout and behavior of different types of views.
        -- Available layouts:
        --  'diff1_plain'
        --    |'diff2_horizontal'
        --    |'diff2_vertical'
        --    |'diff3_horizontal'
        --    |'diff3_vertical'
        --    |'diff3_mixed'
        --    |'diff4_mixed'
        -- For more info, see ':h diffview-config-view.x.layout'.
        default = {
          -- Config for changed files, and staged files in diff views.
          layout = "diff2_horizontal",
          winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
        },
        merge_tool = {
          -- Config for conflicted files in diff views during a merge or rebase.
          layout = "diff3_horizontal",
          disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
          winbar_info = true, -- See ':h diffview-config-view.x.winbar_info'
        },
        file_history = {
          -- Config for changed files in file history views.
          layout = "diff2_horizontal",
          winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
        },
      },
      file_panel = {
        listing_style = "tree", -- One of 'list' or 'tree'
        tree_options = { -- Only applies when listing_style is 'tree'
          flatten_dirs = true, -- Flatten dirs that only contain one single dir
          folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
        },
        win_config = { -- See ':h diffview-config-win_config'
          position = "left",
          width = 35,
          win_opts = {},
        },
      },
      file_history_panel = {
        log_options = { -- See ':h diffview-config-log_options'
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = { -- See ':h diffview-config-win_config'
          position = "bottom",
          height = 16,
          win_opts = {},
        },
      },
      commit_log_panel = {
        win_config = { -- See ':h diffview-config-win_config'
          win_opts = {},
        },
      },
      default_args = { -- Default args prepended to the arg-list for the listed commands
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      hooks = {}, -- See ':h diffview-config-hooks'
      keymaps = {
        disable_defaults = false, -- Disable the default keymaps
        view = {
          -- The `view` bindings are active in the diff buffers, only when the current
          -- tabpage is a Diffview.
          { "n", "<tab>", "<cmd>lua require('diffview.actions').select_next_entry()<CR>", { desc = "Next Entry" } },
          { "n", "<s-tab>", "<cmd>lua require('diffview.actions').select_prev_entry()<CR>", { desc = "Prev Entry" } },
          { "n", "gf", "<cmd>lua require('diffview.actions').goto_file()<CR>", { desc = "Goto File" } },
          {
            "n",
            "<C-w><C-f>",
            "<cmd>lua require('diffview.actions').goto_file_split()<CR>",
            { desc = "Goto File Split" },
          },
          { "n", "<C-w>gf", "<cmd>lua require('diffview.actions').goto_file_tab()<CR>", { desc = "Goto File Tab" } },
          {
            "n",
            "<leader>e",
            "<cmd>lua require('diffview.actions').focus_files()<CR>",
            { desc = "Focus Files" },
          },
          {
            "n",
            "<leader>b",
            "<cmd>lua require('diffview.actions').toggle_files()<CR>",
            { desc = "Toggle Files" },
          },
        },
        file_panel = {
          { "n", "j", "<cmd>lua require('diffview.actions').next_entry()<CR>", { desc = "Next Entry" } },
          { "n", "<down>", "<cmd>lua require('diffview.actions').next_entry()<CR>", { desc = "Next Entry" } },
          { "n", "k", "<cmd>lua require('diffview.actions').prev_entry()<CR>", { desc = "Prev Entry" } },
          { "n", "<up>", "<cmd>lua require('diffview.actions').prev_entry()<CR>", { desc = "Prev Entry" } },
          { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select Entry" } },
          { "n", "o", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select Entry" } },
          { "n", "<2-LeftMouse>", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select Entry" } },
          { "n", "-", "<cmd>lua require('diffview.actions').toggle_stage_entry()<CR>", { desc = "Stage/Unstage" } },
          { "n", "S", "<cmd>lua require('diffview.actions').stage_all()<CR>", { desc = "Stage All" } },
          { "n", "U", "<cmd>lua require('diffview.actions').unstage_all()<CR>", { desc = "Unstage All" } },
          { "n", "X", "<cmd>lua require('diffview.actions').restore_entry()<CR>", { desc = "Restore Entry" } },
          { "n", "R", "<cmd>lua require('diffview.actions').refresh_files()<CR>", { desc = "Refresh" } },
          { "n", "<tab>", "<cmd>lua require('diffview.actions').select_next_entry()<CR>", { desc = "Next Entry" } },
          { "n", "<s-tab>", "<cmd>lua require('diffview.actions').select_prev_entry()<CR>", { desc = "Prev Entry" } },
          { "n", "gf", "<cmd>lua require('diffview.actions').goto_file()<CR>", { desc = "Goto File" } },
          {
            "n",
            "<C-w><C-f>",
            "<cmd>lua require('diffview.actions').goto_file_split()<CR>",
            { desc = "Goto File Split" },
          },
          { "n", "<C-w>gf", "<cmd>lua require('diffview.actions').goto_file_tab()<CR>", { desc = "Goto File Tab" } },
          { "n", "i", "<cmd>lua require('diffview.actions').listing_style()<CR>", { desc = "Toggle Listing Style" } },
          { "n", "f", "<cmd>lua require('diffview.actions').toggle_flatten_dirs()<CR>", { desc = "Flatten Dirs" } },
          {
            "n",
            "<leader>e",
            "<cmd>lua require('diffview.actions').focus_files()<CR>",
            { desc = "Focus Files" },
          },
          {
            "n",
            "<leader>b",
            "<cmd>lua require('diffview.actions').toggle_files()<CR>",
            { desc = "Toggle Files" },
          },
        },
        file_history_panel = {
          { "n", "g!", "<cmd>lua require('diffview.actions').options()<CR>", { desc = "Options" } },
          { "n", "<C-A-d>", "<cmd>lua require('diffview.actions').open_in_diffview()<CR>", { desc = "Open in Diffview" } },
          { "n", "y", "<cmd>lua require('diffview.actions').copy_hash()<CR>", { desc = "Copy Hash" } },
          { "n", "L", "<cmd>lua require('diffview.actions').open_commit_log()<CR>", { desc = "Commit Log" } },
          { "n", "zR", "<cmd>lua require('diffview.actions').open_all_folds()<CR>", { desc = "Open All Folds" } },
          { "n", "zM", "<cmd>lua require('diffview.actions').close_all_folds()<CR>", { desc = "Close All Folds" } },
          { "n", "j", "<cmd>lua require('diffview.actions').next_entry()<CR>", { desc = "Next Entry" } },
          { "n", "<down>", "<cmd>lua require('diffview.actions').next_entry()<CR>", { desc = "Next Entry" } },
          { "n", "k", "<cmd>lua require('diffview.actions').prev_entry()<CR>", { desc = "Prev Entry" } },
          { "n", "<up>", "<cmd>lua require('diffview.actions').prev_entry()<CR>", { desc = "Prev Entry" } },
          { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select Entry" } },
          { "n", "o", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select Entry" } },
          { "n", "<2-LeftMouse>", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select Entry" } },
          { "n", "<tab>", "<cmd>lua require('diffview.actions').select_next_entry()<CR>", { desc = "Next Entry" } },
          { "n", "<s-tab>", "<cmd>lua require('diffview.actions').select_prev_entry()<CR>", { desc = "Prev Entry" } },
          { "n", "gf", "<cmd>lua require('diffview.actions').goto_file()<CR>", { desc = "Goto File" } },
          {
            "n",
            "<C-w><C-f>",
            "<cmd>lua require('diffview.actions').goto_file_split()<CR>",
            { desc = "Goto File Split" },
          },
          { "n", "<C-w>gf", "<cmd>lua require('diffview.actions').goto_file_tab()<CR>", { desc = "Goto File Tab" } },
          {
            "n",
            "<leader>e",
            "<cmd>lua require('diffview.actions').focus_files()<CR>",
            { desc = "Focus Files" },
          },
          {
            "n",
            "<leader>b",
            "<cmd>lua require('diffview.actions').toggle_files()<CR>",
            { desc = "Toggle Files" },
          },
        },
        option_panel = {
          { "n", "<tab>", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select Entry" } },
          { "n", "q", "<cmd>lua require('diffview.actions').close()<CR>", { desc = "Close" } },
        },
      },
    })
  end,
}
