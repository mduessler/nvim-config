return {
	"danymat/neogen",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	keys = {

		{ "<leader>df", "<cmd>Neogen function<CR>", desc = "Neogen function" },
		{ "<leader>dc", "<cmd>Neogen class<CR>", desc = "Neogen class" },
		{ "<leader>dp", "<cmd>Neogen type<CR>", desc = "Neogen type" },
		{ "<leader>df", "<cmd>Neogen file<CR>", desc = "Neogen file" },
	},
	opts = {
		snippet_engine = "luasnip",
		enabled = true,
		languages = {
			lua = { template = { annotation_convention = "ldoc" } },
			sh = { template = { annotation_convention = "sh" } },
			c = { template = { annotation_convention = "doxygen" } },
			cpp = { template = { annotation_convention = "doxygen" } },
			python = { template = { annotation_convention = "numpydoc" } },
			rust = { template = { annotation_convention = "rustdoc" } },
			javascript = { template = { annotation_convention = "jsdoc" } },
			typescript = { template = { annotation_convention = "tsdoc" } },
			typescriptreact = { template = { annotation_convention = "tsdoc" } },
		},
	},
}
