local set = vim.opt_local

vim.opt_local.list = true
vim.opt_local.listchars = { tab = '    ', trail = '·', nbsp = '␣' }
set.shiftwidth = 4 -- Size of an indent
set.tabstop = 4 -- Number of spaces tabs count for
set.softtabstop = 4 -- Number of spaces a tab counts for while editing
vim.opt_local.expandtab = false
