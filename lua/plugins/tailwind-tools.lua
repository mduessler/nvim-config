return {
	"luckasRanarison/tailwind-tools.nvim",
	name = "tailwind-tools",
	build = ":UpdateRemotePlugins",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-telescope/telescope.nvim", -- optional
	},
	ft = { "html", "css", "htmldjango", "jinja2" },
	config = function()
		local tools = require("tailwind-tools")
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "html", "css", "jinja", "htmldjango" },
			callback = function()
				vim.keymap.set(
					"n",
					"<leader>rc",
					"<cmd>TailwindConcealToggle<CR>",
					{ buffer = true, desc = "Conceal classes." }
				)
				vim.keymap.set(
					"n",
					"<leader>rv",
					"<cmd>TailwindColorToggle<CR>",
					{ buffer = true, desc = "Enable/disable colors." }
				)
			end,
		})
		tools.setup({})
	end,
}
