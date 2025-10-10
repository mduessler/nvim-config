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
		seperator = {
			datetime = signs.ui.seperator.default,
			_end = signs.ui.seperator.left.triangle,
		},
	},
}

LOCAL.length = { seperator = { _end = vim.fn.strdisplaywidth(LOCAL.signs.seperator._end) } }

local M = {}

M.get = function()
	local date = table.concat({ "", LOCAL.signs.date, tostring(os.date("%d.%m.%Y")) }, LOCAL.signs.padding)
	local seperator = table.concat({ "", LOCAL.signs.seperator.datetime, "" }, LOCAL.signs.padding)
	local time = table.concat({ LOCAL.signs.time, tostring(os.date("%H:%M")), "" }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(date) + vim.fn.strdisplaywidth(seperator) + vim.fn.strdisplaywidth(time)

	return {
		length = length + LOCAL.length.seperator._end,
		component = table.concat({
			str.highlight("StatuslineDateTimeSepEnd", LOCAL.signs.seperator._end),
			str.highlight("StatuslineDate", date),
			str.highlight("StatuslineDateTimeSep", seperator),
			str.highlight("StatuslineTime", time),
		}),
	}
end

return M
