local is_loaded = false

-- Both assigned by load_debug_stack, so the keymaps at the bottom of the file
-- can reach them without forcing the DAP stack to load at startup.
local apply_project_configs = nil
local project_overrides = nil

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
    -- The default bottom tray is { 'repl', 'console' }. The repl is dropped
    -- from it and reached through <leader>dr as a float instead: while it lived
    -- here, `dap.repl.open()` split a SECOND window onto the same dap-repl
    -- buffer, because nvim-dap tracks its own window handle and knows nothing
    -- about the one dapui owns.
    layouts = {
      {
        elements = {
          { id = 'scopes', size = 0.25 },
          { id = 'breakpoints', size = 0.25 },
          { id = 'stacks', size = 0.25 },
          { id = 'watches', size = 0.25 },
        },
        size = 40,
        position = 'left',
      },
      {
        elements = { 'console' },
        size = 10,
        position = 'bottom',
      },
    },
    controls = {
      -- Defaults to 'repl', which is no longer in a layout -- the winbar
      -- controls would have had nowhere to render.
      element = 'console',
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
    -- Walk up from the BUFFER's directory, not cwd. A monorepo has one uv
    -- project per subtree and the root .venv is rarely the one holding the
    -- imports of the file being debugged; cwd only decides for a buffer that
    -- has no file on disk.
    local from = vim.fn.expand '%:p:h'
    if from == '' then from = vim.fn.getcwd() end
    local venv_dir = vim.fs.find('.venv', { upward = true, path = from, type = 'directory' })[1]
    if venv_dir then
      for _, py in ipairs { venv_dir .. '/bin/python', venv_dir .. '/bin/python3' } do
        if vim.fn.executable(py) == 1 then return py end
      end
    end
    local uv_python = vim.trim(vim.fn.system 'uv python find 2>/dev/null')
    if vim.v.shell_error == 0 and uv_python ~= '' then return uv_python end
    return 'python3'
  end

  -- justMyCode as a DEFAULT, not a load-time rewrite. The old loop mutated
  -- whatever happened to be in dap.configurations.python at that moment, so a
  -- config added later escaped it and a config that set `false` had it
  -- overwritten. on_config runs once per session start and only fills the key
  -- in when the chosen configuration left it unset, so an explicit `false`
  -- survives -- and when nothing pins it, `vim.g.dap_just_my_code` decides.
  --
  -- With it on, debugpy will neither step into nor break inside site-packages,
  -- so <leader>dj is what makes django/db/models reachable. It is read here
  -- rather than baked into each configuration so the toggle applies to every
  -- Python session, including the ones dap-python builds for <leader>dt.
  dap.listeners.on_config['plugin/debug.lua'] = function(config)
    if config.type ~= 'python' or config.justMyCode ~= nil then return config end
    local enriched = vim.deepcopy(config)
    enriched.justMyCode = vim.g.dap_just_my_code ~= false
    return enriched
  end

  ---------------------------------------------------------------------------
  -- Where a Python session runs
  --
  -- The nearest uv project walking up from the BUFFER, not vim.fn.getcwd():
  -- pytest takes its rootdir -- and therefore [tool.pytest.ini_options], and
  -- therefore DJANGO_SETTINGS_MODULE -- from cwd, and a monorepo has several
  -- pyproject.toml to choose between. uv is a given in every project here, so
  -- the venv is always <project>/.venv.
  --
  -- Anything beyond this (env vars, a nested project that is not the nearest
  -- pyproject.toml) belongs in a dap-projects/ overlay, below.
  ---------------------------------------------------------------------------
  local function uv_project_root()
    local from = vim.fn.expand '%:p:h'
    if from == '' then from = vim.fn.getcwd() end
    local found = vim.fs.find('pyproject.toml', { upward = true, path = from, type = 'file' })[1]
    return found and vim.fs.dirname(found) or vim.fn.getcwd()
  end

  local function uv_python()
    local py = uv_project_root() .. '/.venv/bin/python'
    if vim.fn.executable(py) == 1 then return py end
    -- No project venv: fall back to the same resolution the file configs use.
    return require('dap-python').resolve_python()
  end

  ---------------------------------------------------------------------------
  -- Per-project overlays
  --
  -- Each `dap-projects/*.lua` in this config receives the current buffer's git
  -- toplevel as `...` and returns:
  --
  --   { root     = '/abs/path/prefix',        -- which repos it applies to
  --     defaults = { cwd = ..., env = ... },  -- merged into every python session
  --     python   = { <config>, ... } }        -- optional, prepended to <leader>dc
  --
  -- `root` is a path PREFIX, not an exact path, so every git worktree of a repo
  -- matches the one file -- while `...` hands the file the worktree it is
  -- actually running in, so it resolves paths from the live checkout rather
  -- than a hardcoded one.
  --
  -- Living here rather than in the project keeps every repo's tree clean and
  -- keeps these versioned with the rest of the config. Nothing is read out of
  -- a project directory, so there is no vim.secure trust gate to clear.
  ---------------------------------------------------------------------------
  local base_configurations = vim.deepcopy(dap.configurations)
  local project_defaults = {}

  apply_project_configs = function()
    -- Rebuilt from the snapshot on every call, so switching projects -- or
    -- deleting an entry from an overlay -- leaves no stale configurations, and
    -- an edit to an overlay takes effect without restarting nvim.
    dap.configurations = vim.deepcopy(base_configurations)
    project_defaults = {}

    -- No `type` on the find: a git worktree's .git is a FILE, not a directory,
    -- and this repo is checked out as one.
    local from = vim.fn.expand '%:p:h'
    if from == '' then from = vim.fn.getcwd() end
    local dot_git = vim.fs.find('.git', { upward = true, path = from })[1]
    if not dot_git then return end
    local repo = vim.fs.dirname(dot_git)

    for _, file in ipairs(vim.fn.glob(vim.fn.stdpath 'config' .. '/dap-projects/*.lua', false, true)) do
      local chunk, load_err = loadfile(file)
      if not chunk then
        vim.notify(file .. ': ' .. load_err, vim.log.levels.ERROR)
      else
        local ok, spec = pcall(chunk, repo)
        if not ok then
          vim.notify(file .. ': ' .. tostring(spec), vim.log.levels.ERROR)
        elseif type(spec) ~= 'table' or type(spec.root) ~= 'string' then
          vim.notify(file .. ': must return a table with a `root` string', vim.log.levels.ERROR)
        elseif repo:find(spec.root, 1, true) == 1 then
          project_defaults = vim.tbl_extend('force', project_defaults, spec.defaults or {})
          for filetype, configs in pairs(spec) do
            if filetype ~= 'root' and filetype ~= 'defaults' then
              local merged = vim.deepcopy(configs)
              vim.list_extend(merged, dap.configurations[filetype] or {})
              dap.configurations[filetype] = merged
            end
          end
        end
      end
    end
  end

  -- Passed to dap-python's test_method/test_class as `opts.config`, which
  -- accepts a function over the configuration it just built. That config
  -- carries the runner's `module` and `args` and nothing else, so this is
  -- where the interpreter, cwd and any project env get filled in.
  --
  -- justMyCode is left unset on purpose: the on_config listener above supplies
  -- the default, and an overlay's `defaults` can override it to false.
  project_overrides = function(config)
    apply_project_configs()
    return vim.tbl_extend('force', config, {
      cwd = uv_project_root(),
      python = uv_python(),
    }, project_defaults)
  end

  -- Skips dap-python's probe for pytest.ini / manage.py / [tool.pytest...];
  -- pytest is the runner in every Python project here.
  require('dap-python').test_runner = 'pytest'

  is_loaded = true
  return true
end

local function with_dap(callback)
  return function()
    if not load_debug_stack() then return end

    callback()
  end
end

vim.keymap.set('n', '<leader>dc', with_dap(function()
  -- Only on the entry point: continue() with no session is what shows the
  -- configuration picker, and it is the one moment the project file matters.
  if apply_project_configs then apply_project_configs() end
  require('dap').continue()
end), { desc = '[D]ebug: [c]ontinue / start' })
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
vim.keymap.set(
  'n',
  '<leader>dr',
  with_dap(function() require('dapui').float_element('repl', { enter = true }) end),
  { desc = '[D]ebug [r]epl float' }
)
-- Debug one collected pytest test: dap-python finds the nearest `def` above the
-- cursor with treesitter and hands pytest `<file>::<class>::<name>`. There is no
-- `test_` name filter, so in a non-test file this collects nothing and exits
-- cleanly -- the cursor has to be on the test, not on the code under test.
vim.keymap.set(
  'n',
  '<leader>dt',
  with_dap(function() require('dap-python').test_method { config = project_overrides } end),
  { desc = '[D]ebug [t]est under cursor' }
)
vim.keymap.set(
  'n',
  '<leader>dT',
  with_dap(function() require('dap-python').test_class { config = project_overrides } end),
  { desc = '[D]ebug [T]est class under cursor' }
)
-- Off means stepping and breakpoints reach site-packages (Django's ORM); on
-- keeps the debugger inside code you wrote. Takes effect on the next session,
-- not the running one, since debugpy is told at launch.
vim.keymap.set('n', '<leader>dj', function()
  vim.g.dap_just_my_code = vim.g.dap_just_my_code == false
  vim.notify('justMyCode ' .. (vim.g.dap_just_my_code and 'on -- your code only' or 'off -- library code too'))
end, { desc = '[D]ebug: toggle [j]ustMyCode' })
