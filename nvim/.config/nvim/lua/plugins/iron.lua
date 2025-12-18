return {
	"Vigemus/iron.nvim",
	config = function()
		local iron = require("iron.core")
		local view = require("iron.view")
		local common = require("iron.fts.common")

		iron.setup({
			config = {
				scratch_repl = true,
				repl_definition = {
					sh = {
						command = { "bash" },
					},
					python = {
						command = { "ipython", "--no-autoindent" },
						format = common.bracketed_paste_python,
						block_dividers = { "# %%", "#%%" },
					},
				},
				repl_filetype = function(_, ft)
					return ft
				end,
				repl_open_cmd = view.split.vertical.botright(0.40),
			},
			keymaps = {
				toggle_repl = "<leader>rr",
				restart_repl = "<leader>rR",
				send_motion = "<leader>sc",
				visual_send = "<leader>sc",
				send_file = "<leader>sf",
				send_line = "<leader>sl",
				send_paragraph = "<leader>sp",
				send_until_cursor = "<leader>su",
				send_mark = "<leader>sm",
				send_code_block = "<leader>sb",
				send_code_block_and_move = "<leader>sn",
				mark_motion = "<leader>mc",
				mark_visual = "<leader>mc",
				remove_mark = "<leader>md",
				cr = "<leader>s<cr>",
				interrupt = "<leader>s<leader>",
				exit = "<leader>sq",
				clear = "<leader>cl",
			},
			highlight = {
				italic = true,
			},
			ignore_blank_lines = true,
		})

		-- Additional keymaps for commands
		vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<cr>", { desc = "Iron Focus" })
		vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<cr>", { desc = "Iron Hide" })
		vim.keymap.set("n", "<leader>cl", function()
			require("iron.core").send(nil, { "\x0c" }) -- Send Ctrl-L to clear
		end, { desc = "Iron Clear REPL" })
	end,
}
