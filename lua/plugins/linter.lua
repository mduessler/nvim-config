return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>w",
			function()
				require("lint").try_lint()
			end,
			noremap = true,
			silent = true,
			desc = "Lint current buffer",
		},
	},
	config = function()
		local lint = require("lint")
		local tables = require("utils.tables")

		lint.linters_by_ft = {
			sh = { "shellcheck" },
			c = { "cpplint" },
			css = { "stylelint" },
			cmake = { "cmakelint" },
			cpp = { "cpplint" },
			dockerfile = { "hadolint" },
			html = { "djlint" },
			htmldjango = { "djlint" },
			java = { "checkstyle" },
			javascript = { "eslint_d" },
			json = { "jsonlint" },
			lua = { "selene" },
			markdown = { "markdownlint-cli2" },
			python = { "flake8", "mypy" },
			typescript = { "eslint_d" },
			yaml = { "yamllint" },
			-- xml = { "sonarlint-language-server" },
		}

		local flake8 = lint.linters.flake8
		tables.merge_array(flake8.args, { "--max-line-length=120", "--max-doc-length=120" })

		local yamllint = lint.linters.yamllint
		table.insert(yamllint.args, "-c ~/.config/nvim/configs/yamllint.yaml")

		local checkstyle = lint.linters.checkstyle
		table.insert(checkstyle.args, "-c ~/.config/checkstyle-doc.xml")

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
