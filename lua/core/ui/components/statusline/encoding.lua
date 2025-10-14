local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (signs and str) then
	return
end

local LOCAL = {
	signs = {
		separator = signs.ui.separator.right.soft_divider,
		padding = signs.ui.padding,
	},
}

LOCAL.length = {
	separator = vim.fn.strdisplaywidth(LOCAL.separator),
}

LOCAL.hl = {
	separator = str.highlight("StatuslineEncodingSeperator", LOCAL.signs.separator),
}

local M = {}

M.get = function(buf)
	if buf == nil then
		return { length = 0, component = "" }
	end
	local content = table.concat({ "", buf.encoding.representation, "" }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)
	return {
		length = length + LOCAL.length.separator,
		component = LOCAL.hl.separator .. str.highlight("StatuslineEncoding", content),
	}
end

return M
