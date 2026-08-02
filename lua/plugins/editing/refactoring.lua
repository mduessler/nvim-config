local keymap = vim.keymap
local opts = { noremap = true, silent = true }

return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"lewis6991/async.nvim",
	},
	config = function()
		require("refactoring").setup({
			prompt_func_return_type = {
				go = false,
				java = false,
				python = true,
				cpp = false,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			prompt_func_param_type = {
				go = false,
				java = false,
				python = true,
				cpp = false,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			printf_statements = {},
			print_var_statements = {},
			show_success_message = false, -- shows a message with information about the refactor on success
			-- i.e. [Refactor] Inlined 3 variable occurrences
		})

		opts.expr = false
		opts.desc = "Editing"
		keymap.set({ "n", "x" }, "<leader>e", "<NOP>", opts)

		opts.desc = "Selection to method"
		keymap.set("x", "<leader>em", function()
			require("refactoring").refactor("Extract Function")
		end, opts)

		opts.desc = "Selection to method in new file"
		keymap.set("x", "<leader>ef", function()
			require("refactoring").refactor("Extract Function To File")
		end, opts)

		opts.desc = "Create Variable for selection"
		vim.keymap.set("x", "<leader>ev", function()
			require("refactoring").refactor("Extract Variable")
		end, opts)

		opts.desc = "Inline method"
		vim.keymap.set("n", "<leader>eI", function()
			require("refactoring").refactor("Inline Function")
		end, opts)

		opts.desc = "Extract block"
		vim.keymap.set("n", "<leader>eb", function()
			require("refactoring").refactor("Extract Block")
		end, opts)

		opts.desc = "Extract block to file"
		vim.keymap.set("n", "<leader>eB", function()
			require("refactoring").refactor("Extract Block To File")
		end, opts)

		opts.desc = "Create inline variable"
		vim.keymap.set({ "n", "x" }, "<leader>ei", function()
			require("refactoring").refactor("Inline Variable")
		end, opts)
		opts.desc = "Rename"
		vim.keymap.set({ "n", "x" }, "<leader>en", vim.lsp.buf.rename, opts)

		-- opts.desc = "Format current buffer"
		-- keymap.set({ "n", "x" }, "<leader>eq", function()
		-- 	vim.lsp.buf.format({ async = true })
		-- end, opts)
	end,
}
