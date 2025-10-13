return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local require_safe = require("utils.require_safe")
		local formater = require_safe("lsp.formater")
		local linter = require_safe("lsp.linter")
		local ls = require_safe("lsp.servers")
		local mason = require_safe("mason")
		local mason_lspconfig = require_safe("mason-lspconfig")
		local mason_tool_installer = require_safe("mason-tool-installer")
		local signs = require_safe("config.signs")
		local tables = require_safe("utils.tables")

		if
			not (formater and linter and ls and mason and mason_lspconfig and mason_tool_installer and signs and tables)
		then
			return
		end

		local linter_formater = {}
		for _, value in pairs(formater) do
			linter_formater[#linter_formater + 1] = value
		end
		for _, value in pairs(linter) do
			linter_formater[#linter_formater + 1] = value
		end

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
			ensure_installed = linter_formater,
			automatic_installation = true,
		})
	end,
}
