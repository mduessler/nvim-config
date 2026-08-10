return {
	Lua = {
		runtime = {
			version = "LuaJIT",
			path = vim.split(package.path, ";"),
		},
		diagnostics = {
			enable = true,
			globals = { "vim" },
		},
		workspace = {
			library = {
				[vim.fn.expand("$VIMRUNTIME/lua")] = true,
				[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
			},
		},
		telemetry = {
			enable = false,
		},
	},
}
