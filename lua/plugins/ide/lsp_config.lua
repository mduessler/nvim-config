return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		"nvim-lua/plenary.nvim",
		{
			"ray-x/lsp_signature.nvim",
			event = "InsertEnter",
			config = function()
				require("lsp_signature").setup()
			end,
		},
	},
	config = function()
		require("plugins.mason")
		require("lsp.init").setup()
	end,
}
