local is_loaded = false

local function load_debug_stack()
  if is_loaded then
    return true
  end

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
  local ensure_installed = { 'delve', 'debugpy' }

  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed,
    run_on_start = true,
    auto_update = false,
    start_delay = 3000,
  }

  require('mason-nvim-dap').setup {
    automatic_installation = true,
    handlers = {},
    ensure_installed = ensure_installed,
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

  require('dap-python').setup 'python3'

  is_loaded = true
  return true
end

local function with_dap(callback)
  return function()
    if not load_debug_stack() then
      return
    end

    callback()
  end
end

vim.keymap.set('n', '<leader><F5>', with_dap(function() require('dap').continue() end), { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<leader><F10>', with_dap(function() require('dap').step_over() end), { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<leader><F11>', with_dap(function() require('dap').step_into() end), { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<leader><F12>', with_dap(function() require('dap').step_out() end), { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', with_dap(function() require('dap').toggle_breakpoint() end), { desc = '[D]ebug: Toggle [b]reakpoint' })
vim.keymap.set('n', '<leader>dB', with_dap(function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end), { desc = '[D]ebug: Set [B]reakpoint' })
vim.keymap.set('n', '<leader>dl', with_dap(function() require('dapui').toggle() end), { desc = '[D]ebug: See [l]ast session result.' })
vim.keymap.set('n', '<leader>dq', with_dap(function() require('dapui').terminate() end), { desc = '[D]ebug [Q]uit.' })
vim.keymap.set('n', '<leader>dr', with_dap(function() require('dap').repl_open() end), { desc = '[D]ebug [r]epl open' })
