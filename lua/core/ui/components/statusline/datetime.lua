local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (signs and str) then
	return
end

local LOCAL = {
	signs = {
		date = signs.ui.statusline.datetime.date,
		padding = signs.ui.padding,
		time = signs.ui.statusline.datetime.time,
		separator = {
			datetime = signs.ui.separator.default,
			_end = signs.ui.separator.left.triangle,
		},
	},
}

LOCAL.length = { separator = { _end = vim.fn.strdisplaywidth(LOCAL.signs.separator._end) } }

local M = {}

M.get = function()
	local date = table.concat({ "", LOCAL.signs.date, tostring(os.date("%d.%m.%Y")) }, LOCAL.signs.padding)
	local separator = table.concat({ "", LOCAL.signs.separator.datetime, "" }, LOCAL.signs.padding)
	local time = table.concat({ LOCAL.signs.time, tostring(os.date("%H:%M")), "" }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(date) + vim.fn.strdisplaywidth(separator) + vim.fn.strdisplaywidth(time)

	return {
		length = length + LOCAL.length.separator._end,
		component = table.concat({
			str.highlight("StatuslineDateTimeSepEnd", LOCAL.signs.separator._end),
			str.highlight("StatuslineDate", date),
			str.highlight("StatuslineDateTimeSep", separator),
			str.highlight("StatuslineTime", time),
		}),
	}
end

return M
