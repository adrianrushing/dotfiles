vim.pack.add { 'https://github.com/nvim-treesitter/nvim-treesitter' }

local filetypes = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'python',
  'go',
}

require('nvim-treesitter').install(filetypes)
vim.api.nvim_create_autocmd('FileType', {
  pattern = filetypes,
  callback = function() vim.treesitter.start() end,
})
