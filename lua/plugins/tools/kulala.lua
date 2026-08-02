return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {},
	keys = {
		{ "<leader>th", "<NOP>", desc = "HTTP (kulala)" },
		{
			"<leader>thr",
			function()
				require("kulala").run()
			end,
			desc = "Run request under cursor",
		},
		{
			"<leader>thp",
			function()
				require("kulala").copy()
			end,
			desc = "Copy request as cURL command",
		},
		{
			"<leader>thl",
			function()
				require("kulala").replay()
			end,
			desc = "Re-run last request",
		},
	},
}
