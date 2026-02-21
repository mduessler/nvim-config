local require_safe = require("utils.require_safe")

local colors = require_safe("core.colors")

if not colors then
	return
end

local set = vim.api.nvim_set_hl

set(0, "LoggerDEBUG", { fg = colors.default.black })
set(0, "LoggerINFO", { fg = colors.default.green.light })
set(0, "LoggerWARN", { fg = colors.default.yellow })
set(0, "LoggerERROR", { fg = colors.default.red })
set(0, "LoggerTime", { fg = colors.default.blue.light })
set(0, "LoggerMsg", { fg = colors.default.grey })
