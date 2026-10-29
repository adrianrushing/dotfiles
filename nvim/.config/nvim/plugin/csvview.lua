vim.pack.add {
  'https://github.com/hat0uma/csvview.nvim',
}

require('csvview').setup()

vim.keymap.set('n', '<leader>cv', '<cmd>CsvViewToggle<CR>', {
  desc = 'Toggle CSV view',
})
