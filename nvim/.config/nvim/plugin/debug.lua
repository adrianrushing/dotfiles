local is_loaded = false

local function load_debug_stack()
  if is_loaded then return true end

  vim.pack.add {
    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/rcarriga/nvim-dap-ui',
    'https://github.com/nvim-neotest/nvim-nio',
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
    'https://github.com/jay-babu/mason-nvim-dap.nvim',
    'https://github.com/leoluz/nvim-dap-go',
    'https://github.com/mfussenegger/nvim-dap-python',
  }

  local dap = require 'dap'
  local dapui = require 'dapui'
  local ensure_installed = { 'delve', 'debugpy', 'codelldb' }

  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
      args = { '--port', '${port}' },
    },
  }
  local cpp_config = {
    name = 'Launch file',
    type = 'codelldb',
    request = 'launch',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  }
  dap.configurations.c = { cpp_config }
  dap.configurations.cpp = { cpp_config }

  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed,
    run_on_start = true,
    auto_update = false,
    start_delay = 3000,
  }

  require('mason-nvim-dap').setup {
    automatic_installation = true,
    handlers = {},
  }

  dapui.setup {
    icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    controls = {
      icons = {
        pause = '⏸',
        play = '▶',
        step_into = '⏎',
        step_over = '⏭',
        step_out = '⏮',
        step_back = 'b',
        run_last = '▶▶',
        terminate = '⏹',
        disconnect = '⏏',
      },
    },
  }

  vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
  vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })

  local breakpoint_icons = vim.g.have_nerd_font
      and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
  for type, icon in pairs(breakpoint_icons) do
    local sign_name = 'Dap' .. type
    local highlight = type == 'Stopped' and 'DapStop' or 'DapBreak'
    vim.fn.sign_define(sign_name, { text = icon, texthl = highlight, numhl = highlight })
  end

  dap.listeners.after.event_initialized.dapui_config = dapui.open
  dap.listeners.before.event_terminated.dapui_config = dapui.close
  dap.listeners.before.event_exited.dapui_config = dapui.close

  require('dap-go').setup {
    delve = {
      detached = vim.fn.has 'win32' == 0,
    },
    outputMode = 'console',
  }

  require('dap-python').setup(vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python')
  require('dap-python').resolve_python = function()
    local venv = os.getenv 'VIRTUAL_ENV'
    if venv then
      for _, py in ipairs { venv .. '/bin/python', venv .. '/bin/python3' } do
        if vim.fn.executable(py) == 1 then return py end
      end
    end
    -- walk up from cwd to find .venv (handles opening nvim from a subdirectory)
    local venv_dir = vim.fn.finddir('.venv', vim.fn.getcwd() .. ';')
    if venv_dir ~= '' then
      local abs = vim.fn.fnamemodify(venv_dir, ':p')
      for _, py in ipairs { abs .. 'bin/python', abs .. 'bin/python3' } do
        if vim.fn.executable(py) == 1 then return py end
      end
    end
    local uv_python = vim.trim(vim.fn.system 'uv python find 2>/dev/null')
    if vim.v.shell_error == 0 and uv_python ~= '' then return uv_python end
    return 'python3'
  end

  for _, config in ipairs(require('dap').configurations.python or {}) do
    config.justMyCode = true
  end

  is_loaded = true
  return true
end

local function with_dap(callback)
  return function()
    if not load_debug_stack() then return end

    callback()
  end
end

vim.keymap.set('n', '<leader>dc', with_dap(function() require('dap').continue() end), { desc = '[D]ebug: [c]ontinue / start' })
vim.keymap.set('n', '<leader>do', with_dap(function() require('dap').step_over() end), { desc = '[D]ebug: step [o]ver' })
vim.keymap.set('n', '<leader>di', with_dap(function() require('dap').step_into() end), { desc = '[D]ebug: step [i]nto' })
vim.keymap.set('n', '<leader>dO', with_dap(function() require('dap').step_out() end), { desc = '[D]ebug: step [O]ut' })
vim.keymap.set('n', '<leader>db', with_dap(function() require('dap').toggle_breakpoint() end), { desc = '[D]ebug: Toggle [b]reakpoint' })
vim.keymap.set(
  'n',
  '<leader>dB',
  with_dap(function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end),
  { desc = '[D]ebug: Set [B]reakpoint' }
)
vim.keymap.set('n', '<leader>dl', with_dap(function() require('dapui').toggle() end), { desc = '[D]ebug: See [l]ast session result.' })
vim.keymap.set('n', '<leader>dq', with_dap(function() require('dap').terminate() end), { desc = '[D]ebug [Q]uit.' })
vim.keymap.set('n', '<leader>dr', with_dap(function() require('dap').repl_open() end), { desc = '[D]ebug [r]epl open' })
