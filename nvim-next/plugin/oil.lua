vim.pack.add {
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/refractalize/oil-git-status.nvim',
}

_G.CustomOilBar = function()
  local path = vim.fn.expand '%'
  path = path:gsub('oil://', '')
  return '  ' .. vim.fn.fnamemodify(path, ':.')
end

require('oil').setup {
  columns = { 'icon' },
  keymaps = {
    ['<C-h>'] = false,
    ['<C-l>'] = false,
    ['<C-k>'] = false,
    ['<C-j>'] = false,
    ['<M-h>'] = 'actions.select_split',
  },
  win_options = {
    winbar = '%{v:lua.CustomOilBar()}',
    signcolumn = 'yes:2',
  },
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, _)
      local folder_skip = { 'dev-tools.locks', 'dune.lock', '_build' }
      return vim.tbl_contains(folder_skip, name)
    end,
  },
}

require('oil-git-status').setup({})

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

vim.keymap.set('n', '<space>-', function() require('oil').toggle_float() end, { desc = 'Open float parent dir' })
