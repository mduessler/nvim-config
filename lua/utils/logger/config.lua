local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end

local LOCAL = {
	width = 40,
	ns = vim.api.nvim_create_namespace("Logger"),
	windows = {},
	config = {
		path = vim.fn.stdpath("log"),
		name = "nvim",
		files = 2,
		size = 100,
	},
	signs = {
		border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		padding = " ",
		debug = "",
		info = "",
		pass = "",
		warn = "",
		error = "",
		time = signs.ui.statusline.datetime.time,
	},
}

LOCAL.signs.divider = string.rep("─", LOCAL.width)

return LOCAL
