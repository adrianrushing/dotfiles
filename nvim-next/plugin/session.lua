vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/Shatur/neovim-session-manager',
}

local Path = require 'plenary.path'
local config = require 'session_manager.config'
local session_manager = require 'session_manager'

session_manager.setup {
  sessions_dir = Path:new(vim.fn.stdpath 'data', 'sessions'),
  autoload_mode = config.AutoloadMode.Disabled,
  autosave_last_session = true,
  autosave_ignore_not_normal = true,
  autosave_ignore_dirs = {},
  autosave_ignore_filetypes = {
    'gitcommit',
    'gitrebase',
  },
  autosave_ignore_buftypes = {},
  autosave_only_in_session = false,
  max_path_length = 80,
  load_include_current = false,
}

local autosave_group = vim.api.nvim_create_augroup('session-manager-autosave', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = autosave_group,
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'nofile' then
        return
      end
    end

    session_manager.save_current_session()
  end,
})
