vim.pack.add { 'https://github.com/benomahony/uv.nvim' }

require('uv').setup {
  auto_activate_venv = true,
  notify_activate_venv = true,
  auto_commands = true,
  picker_integration = true,
  keymaps = {
    prefix = '<leader>x',
    commands = true,
    run_file = true,
    run_selection = true,
    run_function = true,
    venv = true,
    init = true,
    add = true,
    remove = true,
    sync = true,
    sync_all = true,
  },
  execution = {
    run_command = 'uv run python',
    notify_output = true,
    notification_timeout = 10000,
  },
}
