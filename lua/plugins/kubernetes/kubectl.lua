return {
	"ramilito/kubectl.nvim",
	version = "2.*",
	dependencies = { "saghen/blink.download" },
	keys = {
		{
			"<leader>k",
			function()
				require("kubectl").toggle()
			end,
			mode = "n",
			desc = "Toggle kubectl dashboard",
		},
	},
	config = function()
		require("kubectl").setup()
	end,
}
