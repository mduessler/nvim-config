return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit" },
	},
	config = function()
		require("neogit").setup()
	end,
}
