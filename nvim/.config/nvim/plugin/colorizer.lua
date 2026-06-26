vim.pack.add { 'https://github.com/catgoose/nvim-colorizer.lua' }

require('colorizer').setup {
  filetypes = {
    'css',
    'scss',
    'html',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  user_default_options = {
    css = true,
    tailwind = 'both',
    names = false,
  },
}
