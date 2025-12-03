return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			-- these are examples, not defaults. Please see the readme
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = false

			-- optional, I like wrapping. works for virt text and the output window
			vim.g.molten_wrap_output = true

			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			vim.g.molten_virt_text_output = true

			-- this will make it so the output shows up below the ```` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true

			-- Show output border for better visibility
			vim.g.molten_output_show_more = true
			vim.g.molten_output_win_border = { "", "━", "", "" }

			-- Polars dataframe display optimization
			vim.g.molten_output_win_max_width = 120

			-- keymaps
			vim.keymap.set("n", "<leader>mi", "<cmd>MoltenInit<CR>", { desc = "Molten Init Kernel" })
			vim.keymap.set("n", "<leader>mv", ":MoltenEvaluateOperator<CR>", { desc = "Molten Eval Operator" })
			vim.keymap.set("n", "<leader>ml", "<cmd>MoltenEvaluateLine<CR>", { desc = "Molten Eval Line" })
			vim.keymap.set("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Molten Eval Visual" })

			-- Enhanced cell operations
			vim.keymap.set("n", "<leader>mc", "<cmd>MoltenEvaluateOperator<CR>ip", { desc = "Molten Eval Cell" })
			vim.keymap.set("n", "<leader>mr", "<cmd>MoltenRestart!<CR>", { desc = "Molten Restart Kernel" })
			vim.keymap.set("n", "<leader>mo", "<cmd>MoltenHideOutput<CR>", { desc = "Molten Hide Output" })
			vim.keymap.set("n", "<leader>md", "<cmd>MoltenDelete<CR>", { desc = "Molten Delete Output" })

			-- Evaluate and move to next cell
			vim.keymap.set("n", "<leader>mn", function()
				vim.cmd("MoltenEvaluateOperator")
				vim.cmd("normal! ip")
				-- Move to next cell marker
				vim.fn.search("^# %%", "W")
			end, { desc = "Molten Eval Cell and Move Next" })

			-- Cell navigation (works with # %% markers)
			vim.keymap.set("n", "]c", function()
				vim.fn.search("^# %%", "W")
			end, { desc = "Next Cell" })

			vim.keymap.set("n", "[c", function()
				vim.fn.search("^# %%", "bW")
			end, { desc = "Previous Cell" })
		end,
	},
	{
		-- see the image.nvim readme for more information about configuring this plugin
		"3rd/image.nvim",
		opts = {
			backend = "kitty", -- whatever backend you would like to use
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
