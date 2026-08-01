return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	config = function()
		local ibl = require("ibl")

		vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3b4261", nocombine = true })
		vim.api.nvim_set_hl(0, "IblScope", { fg = "#6e7078", nocombine = true })

		ibl.setup({
			indent = {
				char = "│",
				highlight = "IblIndent",
			},
			scope = {
				enabled = true,
				highlight = "IblScope",
				show_start = false,
				show_end = false,
				show_exact_scope = false,
			},
		})
	end,
}
