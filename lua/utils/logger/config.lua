local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end
---@class LoggerConfig
---@field level string   "DEBUG", "INFO", "WARN", "ERROR"
---@field width number   Width in columns
---@field close number   Timeout in milliseconds
---@field ns number      Namespace ID
---@field windows table   Window handles
---@field timers table    Timer objects
---@field config table    File logging config
---@field config.path string  Log directory
---@field config.name string  Log file name
---@field config.files number Max number of files
---@field config.size number  Max size per file (KB?)
---@field divider string
---@field signs table     Signs configuration
---@field signs.border table   Border characters
---@field signs.divider string
---@field signs.padding string
---@field signs.debug string
---@field signs.info string
---@field signs.pass string
---@field signs.warn string
---@field signs.error string
---@field signs.line string
---@field signs.time string|any   (depends on `signs.ui.statusline.datetime.time`)
local LoggerConfig = {
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
	divider = "",
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

LoggerConfig.divider = string.rep(LoggerConfig.signs.divider, LoggerConfig.width)

return LoggerConfig
