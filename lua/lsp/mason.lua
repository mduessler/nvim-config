local config = {}
config.settings = {
	ui = {
		border = "rounded",
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
	log_level = vim.log.levels.info,
	max_concurrent_installers = 4,
}

config.lsp_conf = {
	ensure_installed = {},
	automatic_installation = true,
}

return config
