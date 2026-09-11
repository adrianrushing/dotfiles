vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then return nil end

    return {
      timeout_ms = 500,
      lsp_format = 'fallback',
    }
  end,
  formatters = {
    -- Without this, conform runs biome even where no biome.json exists (falling
    -- back to the buffer's expandtab), so prettierd would never be reached.
    biome = { require_cwd = true },
  },
  formatters_by_ft = {
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    lua = { 'stylua' },
    python = { 'ruff_fix', 'ruff_format' },
    sql = { 'sqlfluff' },
    go = { 'gofumpt', 'goimports-reviser', 'golines' },
    -- biome wins wherever a biome.json is found, prettierd everywhere else
    javascript = { 'biome', 'prettierd', stop_after_first = true },
    javascriptreact = { 'biome', 'prettierd', stop_after_first = true },
    typescript = { 'biome', 'prettierd', stop_after_first = true },
    typescriptreact = { 'biome', 'prettierd', stop_after_first = true },
    css = { 'biome', 'prettierd', stop_after_first = true },
    json = { 'biome', 'prettierd', stop_after_first = true },
    jsonc = { 'biome', 'prettierd', stop_after_first = true },
    scss = { 'prettierd' },
    html = { 'prettierd' },
    yaml = { 'prettierd' },
    markdown = { 'prettierd' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true, lsp_format = 'fallback' } end, { desc = '[F]ormat buffer' })
