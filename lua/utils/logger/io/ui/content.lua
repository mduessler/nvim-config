local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

local M = {}

local function info_line(content, level, entry)
	local strings = {
		level = LOCAL.signs[level:lower()] .. " " .. level,
		line = LOCAL.signs.line .. tostring(entry) .. " ",
		time = LOCAL.signs.time .. " " .. os.date("%H:%M:%S"),
	}
	local level_width = vim.fn.strdisplaywidth(strings.level)
	local line_width = vim.fn.strdisplaywidth(strings.line)
	local time_width = vim.fn.strdisplaywidth(strings.time)
	strings.padding = LOCAL.signs.padding:rep(LOCAL.width - (3 + level_width + line_width + time_width))
	content[1] = strings
end

M.create = function(level, entry)
	local content = {}
	info_line(content, level, entry)
end

return M
