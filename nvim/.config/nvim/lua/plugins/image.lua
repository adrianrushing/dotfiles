return {
	{
		"3rd/image.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"vhyrro/luarocks.nvim",
		},
		config = function()
			local image = require("image")
			image.setup({
				backend = "kitty",
				processor = "magick_cli",
				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif" },
				integrations = {}, -- do whatever you want with image.nvim's integrations
				max_width = 100, -- tweak to preference
				max_height = 12, -- ^
				max_height_window_percentage = math.huge, -- this is necessary for a good experience
				max_width_window_percentage = math.huge,
				window_overlap_clear_enabled = true,
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			})

			vim.api.nvim_create_user_command("RenderImage", function(opts)
				image.from_file(vim.fn.expand(opts.args))
			end, {
				nargs = 1,
				desc = "Render image by path",
			})
		end,
	},
}
