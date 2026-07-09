vim.pack.add {
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/rcarriga/nvim-notify',
  'https://github.com/goolord/alpha-nvim',
}

require('tokyonight').setup {
  styles = {
    comments = { italic = false },
  },
}

vim.cmd.colorscheme 'tokyonight-night'

require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
  },
  spec = {
    { 's', group = '[S]urround', mode = { 'n', 'v' } },
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  },
}

local notify = require 'notify'
notify.setup {
  top_down = false,
}

vim.notify = notify

local alpha = require 'alpha'
local dashboard = require 'alpha.themes.dashboard'

dashboard.section.header.val = {
  [[                               __                ]],
  [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
  [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
  [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
  [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
  [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
}

dashboard.section.buttons.val = {
  dashboard.button('e', '  New file', ':ene <BAR> startinsert <CR>'),
  dashboard.button('r', '󱂬  Restore Last Session', '<cmd>SessionManager load_current_dir_session<CR>'),
  dashboard.button('q', '󰅚  Quit NVIM', ':qa<CR>'),
}

if vim.fn.executable 'fortune' == 1 then
  local handle = io.popen 'fortune'
  if handle ~= nil then
    local fortune = handle:read '*a'
    handle:close()
    dashboard.section.footer.val = fortune
  end
else
  dashboard.section.footer.val = 'Welcome back.'
end

dashboard.config.opts.noautocmd = true
alpha.setup(dashboard.config)
