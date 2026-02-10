return {
  'danymat/neogen',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('neogen').setup {
      enabled = true,
      -- Set to 'google' for Google-style docstrings
      languages = {
        python = {
          template = {
            annotation_convention = 'google_docstrings',
          },
        },
      },
    }

    -- Keymap to generate docstring for the function/class under the cursor
    vim.keymap.set('n', '<leader>cn', function()
      require('neogen').generate()
    end, { desc = 'Code: [N]eogen Docstring' })
  end,
}
