vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()

local indentscope = require 'mini.indentscope'
indentscope.setup {
  symbol = '│',
  draw = {
    delay = 0,
    animation = indentscope.gen_animation.none(),
  },
}

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
statusline.section_location = function() return '%2l:%-2v' end
