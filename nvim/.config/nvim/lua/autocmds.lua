-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Set terminal to no buffer',
  group = vim.api.nvim_create_augroup('kickstart-term-no-write', { clear = true }),
  callback = function()
    vim.opt_local.buftype = 'nofile'
  end,
})

-- vim: ts=2 sts=2 sw=2 et
