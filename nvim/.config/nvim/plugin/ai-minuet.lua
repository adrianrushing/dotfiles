-- Keep this file alphabetically before completion.lua: blink.cmp's config requires
-- Minuet to already be available when it creates the manual completion mapping.
vim.pack.add { 'https://github.com/milanglacier/minuet-ai.nvim' }

require('minuet').setup {
  virtualtext = {
    auto_trigger_ft = {},
    keymap = {
      accept = '<A-a>',
      accept_line = '<A-l>',
      next = '<A-]>',
      prev = '<A-[>',
      dismiss = '<A-e>',
    },
  },
  provider = 'openai_fim_compatible',
  n_completions = 1,
  request_timeout = 10,
  provider_options = {
    openai_fim_compatible = {
      name = 'Qwen3 Coder (GPU cluster)',
      end_point = 'http://172.30.1.20:8002/v1/completions',
      model = 'qwen3-coder-next-fp8',
      api_key = function()
        return 'not-needed'
      end,
      stream = false,
      template = {
        prompt = function(context_before_cursor, context_after_cursor)
          local utils = require 'minuet.utils'

          return '<|fim_prefix|>'
            .. utils.add_language_comment()
            .. '\n'
            .. utils.add_tab_comment()
            .. '\n'
            .. context_before_cursor
            .. '<|fim_suffix|>'
            .. context_after_cursor
            .. '<|fim_middle|>'
        end,
        suffix = false,
      },
      optional = {
        max_tokens = 128,
        temperature = 0,
        stop = { '<|fim_pad|>', '<|endoftext|>', '<|file_sep|>' },
      },
    },
  },
}

vim.keymap.set('n', '<leader>at', '<cmd>Minuet virtualtext toggle<CR>', {
  desc = 'Toggle Minuet virtual text',
})
