local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end

local LOCAL = {
	level = os.getenv("NVIM_LOG_LEVEL") or "INFO",
	width = 40,
	close = 10000,
	ns = vim.api.nvim_create_namespace("Logger"),
	windows = {},
	timers = {},
	config = {
		path = vim.fn.stdpath("log"),
		name = "nvim",
		files = 2,
		size = 100,
	},
	signs = {
		border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		divider = "─",
		padding = " ",
		debug = "",
		info = "",
		pass = "",
		warn = "",
		error = "",
		line = "",
		time = signs.ui.statusline.datetime.time,
	},
}

LOCAL.divider = string.rep(LOCAL.signs.divider, LOCAL.width)

return LOCAL
