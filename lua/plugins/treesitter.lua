return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- der main-Branch unterstützt kein Lazy-Loading
	priority = 999,
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup({})

		-- Installiert alle verfügbaren Parser; no-op für bereits installierte
		ts.install({ "all" })

		-- Highlighting + Indent macht Neovim selbst, pro Buffer aktiviert,
		-- sobald ein Parser für den Filetype existiert
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_features", { clear = true }),
			callback = function(args)
				local started = pcall(vim.treesitter.start, args.buf)
				if started then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		require("nvim-ts-autotag").setup()
	end,
}
