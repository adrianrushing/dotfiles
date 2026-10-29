vim.pack.add { 'https://github.com/nvim-treesitter/nvim-treesitter' }

local filetypes = {
  'bash',
  'c',
  'cpp',
  'diff',
  'html',
  'javascript',
  'typescript',
  'tsx',
  'css',
  'scss',
  'json',
  'yaml',
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

-- `filetypes` holds parser names; FileType events use filetype names (tsx ->
-- typescriptreact, vimdoc -> help, ...), so map them before building the pattern.
local patterns = {}
for _, lang in ipairs(filetypes) do
  vim.list_extend(patterns, vim.treesitter.language.get_filetypes(lang))
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = patterns,
  -- pcall: on first launch the parser may still be installing.
  callback = function() pcall(vim.treesitter.start) end,
})
