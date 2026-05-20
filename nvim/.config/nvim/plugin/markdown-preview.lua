local is_loaded = false

local function load_markdown_preview()
  if is_loaded then
    return true
  end

  vim.pack.add {
    'https://github.com/selimacerbas/live-server.nvim',
    'https://github.com/selimacerbas/markdown-preview.nvim',
  }

  local ok, markdown_preview = pcall(require, 'markdown_preview')
  if not ok then
    vim.notify('Failed to load markdown-preview.nvim', vim.log.levels.ERROR)
    return false
  end

  markdown_preview.setup {
    port = 8421,
    open_browser = true,
    debounce_ms = 300,
  }

  is_loaded = true
  return true
end

vim.api.nvim_create_user_command('MarkdownPreview', function()
  if not load_markdown_preview() then
    return
  end

  vim.cmd 'MarkdownPreviewToggle'
end, { desc = 'Lazy-load and toggle markdown preview' })
