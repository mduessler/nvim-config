local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (signs and str) then
	return
end

local LOCAL = {
	signs = {
		seperator = signs.ui.seperator.right.soft_divider,
		padding = signs.ui.padding,
	},
}

LOCAL.length = {
	seperator = vim.fn.strdisplaywidth(LOCAL.seperator),
}

LOCAL.hl = {
	seperator = str.highlight("StatuslineEncodingSeperator", LOCAL.signs.seperator),
}

local M = {}

M.get = function(buf)
	if buf == nil then
		return { length = 0, component = "" }
	end
	local content = table.concat({ "", buf.encoding.representation, "" }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)
	return { length = length, component = LOCAL.hl.seperator .. str.highlight("StatuslineEncoding", content) }
end

return M
