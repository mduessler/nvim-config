return {
	"rest-nvim/rest.nvim",
	tag = "v2.0.1", -- letzte Version ohne LuaRocks-Abhängigkeiten
	ft = "http",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("rest-nvim").setup()

		vim.keymap.set("n", "<leader>h", "<NOP>", { desc = "HTTP (rest.nvim)" })
		vim.keymap.set("n", "<leader>hr", "<Plug>RestNvim", { desc = "Run request under cursor" })
		vim.keymap.set("n", "<leader>hp", "<Plug>RestNvimPreview", { desc = "Preview cURL command" })
		vim.keymap.set("n", "<leader>hl", "<Plug>RestNvimLast", { desc = "Re-run last request" })
	end,
}
