return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local require_safe = require("utils.require_safe")
		local ls = require_safe("lsp.servers")
		local mason = require_safe("mason")
		local mason_lspconfig = require_safe("mason-lspconfig")
		local mason_tool_installer = require_safe("mason-tool-installer")
		local signs = require_safe("config.signs")
		local tables = require_safe("utils.tables")

		if not (ls and mason and mason_lspconfig and mason_tool_installer and signs and tables) then
			return
		end

		local linter = {
			"shellcheck", -- Bash
			"markdownlint-cli2", -- Markdown ls
			"selene", -- Lua ls
			"eslint_d", -- JS, TS
			"jsonlint", -- JSON
			"stylelint", -- CSS, HTML
			"hadolint", -- Docker
			"djlint", -- Djlint
			"flake8", -- Python
			"mypy", -- Python
			"htmlhint", --Html
			"cpplint", -- C, c++ ...,
			-- "cmakelang", -- Cmake
			"cmakelint",
			"yamllint", -- Yaml
		}
		local formater = {
			"shfmt", -- Bash
			"mdformat", -- Markdown ls
			"stylua", -- Lua ls
			"prettier", -- JavaScript, TypeScript, JSON, CSS
			"black", -- Python
			"isort", -- Python
			"djlint", -- Djlint
			"docformatter", -- Python
			"clang-format", -- C, c++ ...,
			"cmakelang", -- Cmake
			"yamlfmt", -- Yaml
			"beautysh", -- zsh
			-- "eslint",
		}

		local lsp = {}
		for _, value in pairs(ls) do
			lsp[#lsp + 1] = value
		end

		mason.setup({
			ui = {
				border = "rounded",
				icons = signs.mason,
			},
			log_level = vim.log.levels.info,
			max_concurrent_installers = 4,
		})
		mason_lspconfig.setup({ ensure_installed = lsp, automatic_installation = true, automatic_enable = false })

		mason_tool_installer.setup({
			ensure_installed = tables.merge_array(linter, formater),
			automatic_installation = true,
		})
	end,
}
