local M = {}

function M.setup()
  require('lazydev').setup {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  }

  require('mason').setup()
  require('fidget').setup()

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      local telescope_ok, telescope_builtin = pcall(require, 'telescope.builtin')

      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
      map('grr', telescope_ok and telescope_builtin.lsp_references or vim.lsp.buf.references, '[G]oto [R]eferences')
      map('K', vim.lsp.buf.hover, 'Hover Documentation')
      map('gri', telescope_ok and telescope_builtin.lsp_implementations or vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      map('grd', telescope_ok and telescope_builtin.lsp_definitions or vim.lsp.buf.definition, '[G]oto [D]efinition')
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      map('grt', telescope_ok and telescope_builtin.lsp_type_definitions or vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')

      if telescope_ok then
        map('gO', telescope_builtin.lsp_document_symbols, 'Open Document Symbols')
        map('gW', telescope_builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
      end

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
    } or {},
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      format = function(diagnostic) return diagnostic.message end,
    },
    jump = { float = true },
  }

  local blink_ok, blink = pcall(require, 'blink.cmp')
  local capabilities = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()
  local util = require 'lspconfig.util'

  local lua_project_root = util.root_pattern('.luarc.json', '.luarc.jsonc', '.git', '.stylua.toml', 'stylua.toml', 'selene.toml', 'lua', 'init.lua')

  local function lua_ls_root_dir(fname)
    local root = lua_project_root(fname)
    if not root then return nil end

    local homedir = (vim.uv or vim.loop).os_homedir()
    if not homedir then return root end

    local normalized_root = vim.fs.normalize(root)
    local normalized_home = vim.fs.normalize(homedir)
    if normalized_root == normalized_home then return nil end

    return root
  end

  local servers = {
    clangd = { cmd = { 'clangd', '--background-index', '--cland-tidy', '--completion-style=detailed', '--header-insertion=iwyu' } },
    gopls = {
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
      cmd = { 'gopls' },
      root_dir = util.root_pattern('go.work', 'go.mod', '.git'),
      settings = {
        hints = {
          rangeVariableTypes = true,
          parameterNames = true,
          ignoredError = true,
          functionTypeParameters = true,
          constantValues = true,
          compositeLiteralTypes = true,
          compositeLiteralFields = true,
          assignVariableTypes = true,
        },
        completeUnimported = true,
        usePlaceholders = true,
        analyses = { unusedparams = true },
      },
    },
    ty = { completions = { autoImport = true } },
    ruff = {
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.completionProvider = false
      end,
    },
    ts_ls = {
      capabilities = {
        documentFormattingProvider = false,
        documentRangeFormattingProvider = false,
      },
      settings = {
        typescript = {
          implementationsCodeLens = true,
          referencesCodeLens = true,
          format = {
            indentSize = 2,
            tabSize = 2,
          },
        },
        javascript = {
          format = {
            indentSize = 2,
            tabSize = 2,
          },
        },
      },
    },
    tailwindcss = {},
    biome = {},
    lua_ls = {
      root_dir = lua_ls_root_dir,
      settings = {
        Lua = {
          completion = {},
        },
      },
    },
    marksman = {},
  }

  local ensure_installed = vim.tbl_keys(servers)
  vim.list_extend(ensure_installed, {
    'stylua',
    'biome',
    'clangd',
  })

  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed,
    run_on_start = true,
    auto_update = false,
    start_delay = 3000,
  }

  require('mason-lspconfig').setup {
    ensure_installed = {},
    automatic_installation = true,
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }
end

return M
