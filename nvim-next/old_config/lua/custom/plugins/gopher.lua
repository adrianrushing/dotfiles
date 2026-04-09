return {
  'olexsmir/gopher.nvim',
  ft = 'go',
  dependencies = { -- These are usually required for gopher to work well
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  build = function() vim.cmd.GoInstallDeps() end,
  opts = {},
}
