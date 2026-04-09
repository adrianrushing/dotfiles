-- debug.lua
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    {
      '<leader><F5>',
      function() require('dap').continue() end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<leader><F10>',
      function() require('dap').step_over() end,
      desc = 'Debug: Step Over',
    },
    {
      '<leader><F11>',
      function() require('dap').step_into() end,
      desc = 'Debug: Step Into',
    },
    {
      '<leader><F12>',
      function() require('dap').step_out() end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>db',
      function() require('dap').toggle_breakpoint() end,
      desc = '[D]ebug: Toggle [b]reakpoint',
    },
    {
      '<leader>dB',
      function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
      desc = '[D]ebug: Set [B]reakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>dl',
      function() require('dapui').toggle() end,
      desc = '[D]ebug: See [l]ast session result.',
    },
    {
      '<leader>dq',
      function() require('dapui').terminate() end,
      desc = '[D]ebug [Q]uit.',
    },
    {
      '<leader>dr',
      function() require('dap').repl_open() end,
      desc = '[D]ebug [r]epl open',
    },
  },
  config = function()
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
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
      outputMode = 'console',
    }
    local dap_python = require 'dap-python'
    dap_python.setup 'python3'
    -- Install python specific config
    -- require('dap-python').setup 'uv'
  end,
}
