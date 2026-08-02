return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {},
	keys = {
		{ "<leader>h", "<NOP>", desc = "HTTP (kulala)" },
		{
			"<leader>hr",
			function()
				require("kulala").run()
			end,
			desc = "Run request under cursor",
		},
		{
			"<leader>hp",
			function()
				require("kulala").copy()
			end,
			desc = "Copy request as cURL command",
		},
		{
			"<leader>hl",
			function()
				require("kulala").replay()
			end,
			desc = "Re-run last request",
		},
	},
}
