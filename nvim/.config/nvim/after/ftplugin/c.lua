local set = vim.opt_local

set.shiftwidth = 4
set.tabstop = 4
set.softtabstop = 4
set.expandtab = true

local file = vim.fn.expand '%:p'
local output = vim.fn.expand '%:p:r'

local function open_term(cmd)
  vim.cmd('botright 12split')
  vim.cmd('terminal ' .. cmd)
end

vim.keymap.set('n', '<leader>mc', function()
  vim.cmd.write()
  local cmd = 'gcc -g ' .. vim.fn.shellescape(file) .. ' -o ' .. vim.fn.shellescape(output)
  open_term(cmd)
end, { buffer = true, desc = '[C] build with gcc' })

vim.keymap.set('n', '<leader>mr', function()
  local run_cmd = vim.fn.shellescape(output)
  open_term(run_cmd)
end, { buffer = true, desc = '[R]un compiled binary' })
