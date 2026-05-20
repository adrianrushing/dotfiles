if vim.g.enable_nvim_lint ~= true then
  return
end

vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

local lint = require 'lint'
lint.linters_by_ft = {
  markdown = { 'markdownlint' },
  json = { 'jsonlint' },
}
