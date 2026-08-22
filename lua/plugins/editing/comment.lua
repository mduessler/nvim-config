return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	opts = function()
		return {
			padding = true,
			sticky = true,
			ignore = nil,
			toggler = { line = "<leader>gc", block = "<leader>gb" },
			opleader = { line = "<leader>gc", block = "<leader>gb" },
			extra = {
				above = "gcO",
				below = "gco",
				eol = "gcA",
			},
			mappings = {
				basic = false,
				extra = false,
			},
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			post_hook = nil,
		}
	end,
}
