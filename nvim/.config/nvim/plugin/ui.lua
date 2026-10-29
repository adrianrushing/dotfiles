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

local theme_link = vim.fn.expand '~/.config/theme/current'
local last_theme_mode

local function theme_mode()
  local target = vim.uv.fs_readlink(theme_link)
  if target and target:match 'light$' then
    return 'light'
  end
  return 'dark'
end

local function apply_theme(force)
  local mode = theme_mode()
  if not force and mode == last_theme_mode then
    return
  end

  last_theme_mode = mode
  vim.o.background = mode
  vim.cmd.colorscheme(mode == 'light' and 'tokyonight-day' or 'tokyonight-night')
end

apply_theme(true)

vim.api.nvim_create_user_command('ThemeToggle', function()
  local script = vim.fn.expand '~/.local/bin/theme-toggle'
  local output = vim.fn.system { script }
  if vim.v.shell_error ~= 0 then
    vim.notify(output, vim.log.levels.ERROR)
    return
  end
  apply_theme(true)
  vim.notify(vim.trim(output))
end, { desc = 'Toggle TokyoNight light/dark mode' })

vim.keymap.set('n', '<leader>tt', '<cmd>ThemeToggle<CR>', { desc = '[T]oggle color theme' })

vim.api.nvim_create_autocmd({ 'FocusGained', 'TermLeave' }, {
  desc = 'Follow the shared TokyoNight mode',
  callback = function()
    apply_theme(false)
  end,
})

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
