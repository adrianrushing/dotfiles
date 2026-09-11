vim.pack.add { 'https://github.com/kevalin/mermaid.nvim.git' }

require('mermaid').setup {
  format = {
    shift_width = 4, -- Indentation size (spaces)
  },
  lint = {
    enabled = true, -- Enable diagnostics via mmdc
    command = 'mmdc', -- Path to mermaid-cli executable
  },
  preview = {
    port = 0, -- Server port (0 or nil for random available port)
    renderer = 'mermaid.js', -- "mermaid.js" or "beautiful-mermaid"
    theme = 'default', -- Theme name (renderer-specific)
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'mermaid',
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.keymap.set('n', '<leader>mp', '<cmd>MermaidPreview<CR>', { buffer = buf, desc = 'Mermaid Preview' })
    vim.keymap.set('n', '<leader>mf', '<cmd>MermaidFormat<CR>', { buffer = buf, desc = 'Mermaid Format' })
    vim.keymap.set('n', '<leader>mr', '<cmd>MermaidRender<CR>', { buffer = buf, desc = 'Mermaid Render' })
    vim.keymap.set('n', '<leader>mc', '<cmd>MermaidCopyURL<CR>', { buffer = buf, desc = 'Mermaid Copy URL' })
    vim.keymap.set('n', '<leader>mx', '<cmd>MermaidPreviewStop<CR>', { buffer = buf, desc = 'Mermaid Stop Preview' })
  end,
})

-- Override :MermaidRender.
--
-- Upstream renders with chafa, which is a dead end for flowcharts: chafa paints
-- with terminal cells, so a wide diagram scaled to fit loses all its label text.
-- (Upstream also captures chafa's output with vim.fn.system() and discards it,
-- so nothing was ever drawn either way.)
--
-- Ghostty speaks the kitty graphics protocol, so draw a real image. tmux filters
-- the protocol's APC sequences unless they are wrapped in DCS passthrough, and
-- placements have to be tracked as the window moves -- image.nvim handles both.
vim.pack.add { 'https://github.com/3rd/image.nvim.git' }

require('image').setup {
  processor = 'magick_cli', -- CLI wrapping, so no luarocks/magick rock build
  backend = 'kitty',
  integrations = {}, -- no document auto-rendering; this config only wants the API
  max_width_window_percentage = 100,
  max_height_window_percentage = 100,
  window_overlap_clear_enabled = true,
  -- Kitty placements are absolute terminal coordinates, so without this an image
  -- keeps painting over whatever tmux window you switch to.
  tmux_show_only_in_active_window = true,
  editor_only_render_when_focused = true,
}

-- Cells of clear space between the float's border and the image.
local PAD_X, PAD_Y = 2, 1

vim.api.nvim_create_user_command('MermaidRender', function()
  local src_win = vim.api.nvim_get_current_win()
  local src = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

  -- A 'rounded' border is drawn outside the requested size, so leave it a cell
  -- on each side to keep the float within the source window's bounds.
  local width = vim.api.nvim_win_get_width(src_win) - 2
  local height = vim.api.nvim_win_get_height(src_win) - 2
  if width - PAD_X * 2 < 20 or height - PAD_Y * 2 < 10 then
    vim.notify('Window too small to render the diagram', vim.log.levels.WARN)
    return
  end

  local mmd, png = vim.fn.tempname() .. '.mmd', vim.fn.tempname() .. '.png'
  vim.fn.writefile(vim.split(src, '\n'), mmd)

  -- Wide fixed pixel width so labels survive being scaled into the window.
  local theme = vim.o.background == 'light' and 'default' or 'dark'
  local out = vim.fn.system {
    'mmdc', '-i', mmd, '-o', png, '-t', theme, '-b', 'transparent', '-w', '2400',
  }
  pcall(os.remove, mmd)
  if vim.v.shell_error ~= 0 then
    vim.notify('mmdc failed: ' .. out, vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'win',
    win = src_win,
    width = width,
    height = height,
    row = 0,
    col = 0,
    border = 'rounded',
    title = ' Mermaid ',
    title_pos = 'center',
  })
  vim.wo[win].winfixbuf = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'

  -- Inset the image so it does not paint over the border or the title.
  local img = require('image').from_file(png, {
    window = win,
    buffer = buf,
    x = PAD_X,
    y = PAD_Y,
    width = width - PAD_X * 2,
    height = height - PAD_Y * 2,
  })
  img:render()

  -- window_overlap_clear_enabled only tracks normal splits overlapping the
  -- image, so anything drawn in another float -- Telescope, for one -- gets
  -- clipped through. Drop the placement whenever the float loses focus and put
  -- it back on return.
  vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
    buffer = buf,
    callback = function()
      pcall(function() img:clear() end)
    end,
  })
  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        pcall(function() img:render() end)
      end
    end,
  })

  -- Neovim closes a window-relative float on its own when the source window
  -- goes away, so clean up on wipeout rather than only in the close mappings.
  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = buf,
    once = true,
    callback = function()
      pcall(function() img:clear() end)
      pcall(os.remove, png)
    end,
  })

  for _, key in ipairs { 'q', '<Esc>' } do
    vim.keymap.set('n', key, function()
      img:clear()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf, nowait = true })
  end
end, { desc = 'Render Mermaid diagram as an image (image.nvim)' })
