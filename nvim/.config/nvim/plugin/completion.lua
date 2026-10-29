vim.pack.add {
  'https://github.com/saghen/blink.cmp',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/rafamadriz/friendly-snippets',
}

require('luasnip.loaders.from_vscode').lazy_load()

require('blink.cmp').setup {
  keymap = {
    preset = 'default',
    ['<A-y>'] = require('minuet').make_blink_map(),
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
    -- Let Blink trigger normal LSP completion automatically, while avoiding
    -- speculative provider requests as soon as Insert mode starts.
    trigger = { prefetch_on_insert = false },
  },
  sources = {
    -- Keep Minuet manual-only via <A-y>; normal completion stays fast and local.
    default = { 'lsp', 'path', 'snippets', 'lazydev' },
    per_filetype = {
      sql = { 'snippets', 'dadbod', 'buffer' },
      mysql = { 'snippets', 'dadbod', 'buffer' },
      plsql = { 'snippets', 'dadbod', 'buffer' },
    },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
      minuet = {
        name = 'Minuet',
        module = 'minuet.blink',
        async = true,
        timeout_ms = 10000,
        score_offset = 50,
      },
    },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
}
