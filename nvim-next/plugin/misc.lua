vim.pack.add {
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/ellisonleao/dotenv.nvim',
}

require('guess-indent').setup {}
require('dotenv').setup { enable_on_load = true, verbose = false }
