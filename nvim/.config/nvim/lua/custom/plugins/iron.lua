return {
  {
    'Vigemus/iron.nvim',
    config = function()
      local iron = require 'iron.core'
      local view = require 'iron.view'
      local common = require 'iron.fts.common'
      iron.setup {
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              -- Can be a table or a function that
              -- returns a table (see below)
              command = { 'zsh' },
            },
            python = {
              command = { 'python3' }, -- or { "ipython", "--no-autoindent" }
              format = common.bracketed_paste_python,
              block_dividers = { '# %%', '#%%' },
              env = { PYTHON_BASIC_REPL = '1' }, --this is needed for python3.13 and up.
            },
          },
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = require('iron.view').split.vertical.botright(0.3),
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          -- send_motion = '<space>rsc',
          -- visual_send = '<space>rsc',
          -- send_file = '<space>rsf',
          -- send_line = '<space>rsl',
          -- send_mark = '<space>rsm',
          -- mark_motion = '<space>rmc',
          -- mark_visual = '<space>rmc',
          -- remove_mark = '<space>rmd',
          cr = '<space>rs<cr>',
          interrupt = '<space>rs<space>',
          exit = '<space>rq',
          clear = '<space>rx',
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }

      -- iron also has a list of commands, see :h iron-commands for all available commands

      vim.keymap.set('n', '<space>rsc', iron.send_motion, { desc = 'REPL [S]end [C]hunk' })
      vim.keymap.set('v', '<space>rsc', iron.visual_send, { desc = 'REPL [S]end [C]hunk' })
      vim.keymap.set('n', '<space>rsf', iron.send_file, { desc = 'REPL [S]end [F]ile' })
      vim.keymap.set('n', '<space>rsl', iron.send_line, { desc = 'REPL [S]end [L]ine' })
      vim.keymap.set('n', '<space>rmd', iron.send_mark, { desc = 'REPL [S]end [M]ark' })
      vim.keymap.set('n', '<space>rmc', iron.mark_motion, { desc = 'REPL [M]ark [C]hunk' })
      vim.keymap.set('v', '<space>rmc', iron.mark_visual, { desc = 'REPL [M]ark [C]hunk' })
      vim.keymap.set({ 'v', 'n' }, '<space>rsu', iron.send_until_cursor, { desc = 'REPL [S]end [U]ntil Cursor' })
      vim.keymap.set('n', '<space>rt', '<cmd>IronRepl<cr>', { desc = 'REPL [T]oggle' })
      vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>', { desc = 'REPL [R]estart' })
      vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>', { desc = 'REPL [F]ocus' })
      vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>', { desc = 'REPL [H]ide' })
    end,
  },
}
