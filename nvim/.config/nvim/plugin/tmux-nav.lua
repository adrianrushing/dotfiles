vim.pack.add { 'https://github.com/christoomey/vim-tmux-navigator' }

vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>')
vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>')
vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>')
vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>')

vim.keymap.set('t', '<C-h>', '<C-\\><C-n><cmd>TmuxNavigateLeft<CR>')
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><cmd>TmuxNavigateDown<CR>')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><cmd>TmuxNavigateUp<CR>')
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><cmd>TmuxNavigateRight<CR>')
