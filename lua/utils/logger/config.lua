local LOCAL = {
	width = 40,
	ns = {
		time = vim.api.nvim_create_namespace("LoggerTime"),
		divider = vim.api.nvim_create_namespace("LoggerDivider"),
		msg = vim.api.nvim_create_namespace("LoggerMsg"),
	},
	windows = {},
	config = {
		path = vim.fn.stdpath("log"),
		name = "nvim",
		files = 2,
		size = 100,
	},
	signs = {
		debug = "",
		info = "",
		warn = "",
		error = "",
	},
}

LOCAL.signs = {
	divider = string.rep("─", LOCAL.width),
}

return LOCAL
