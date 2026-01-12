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

			-- Reserve space for output via virtual lines
			vim.g.molten_output_virt_lines = true

			-- Force images to be virtual text (inline)
			vim.g.molten_image_location = "float"

			-- Use border highlights for better image anchoring
			vim.g.molten_use_border_highlights = true

			-- Polars dataframe display optimization
			vim.g.molten_output_win_max_width = 120

			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

			-- keymaps
			vim.keymap.set("n", "<leader>mi", "<cmd>MoltenInit<CR>", { desc = "Molten Init Kernel" })
			vim.keymap.set("n", "<leader>mv", ":MoltenEvaluateOperator<CR>", { desc = "Molten Eval Operator" })
			vim.keymap.set("n", "<leader>ml", "<cmd>MoltenEvaluateLine<CR>", { desc = "Molten Eval Line" })
			vim.keymap.set("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Molten Eval Visual" })
		end,
	},
}
