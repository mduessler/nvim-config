local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (signs and str) then
	return
end

local LOCAL = {
	signs = {
		separator = signs.ui.separator.default,
		padding = signs.ui.padding,
	},
}

LOCAL.length = {
	separator = vim.fn.strdisplaywidth(LOCAL.signs.separator),
	padding = vim.fn.strdisplaywidth(LOCAL.signs.padding),
}

local M = {}

M.get = function(win)
	if not win or not win.position_str then
		return { length = 0, component = "" }
	end

	local content = table.concat({ "", LOCAL.signs.separator, win.position_str() }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)

	return { length = length, component = str.highlight("StatuslinePosition", content) }
end

return M
