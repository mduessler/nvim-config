local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

local M = {}

M.create = function(level, entry)
	local content = {}

	local function info_line()
		local level_string = LOCAL.signs[level:lower()] .. " " .. level
		local level_width = vim.fn.strdisplaywidth(level_string)
		local line_string = LOCAL.signs.line .. tostring(entry) .. " "
		local line_width = vim.fn.strdisplaywidth(line_string)
		local time_string = LOCAL.signs.time .. " " .. os.date("%H:%M:%S")
		local time_width = vim.fn.strdisplaywidth(time_string)
		local line_time_pad = 3

		local components = {
			level_string,
			LOCAL.signs.padding:rep(LOCAL.width - (2 + level_width + line_width + line_time_pad + time_width)),
			line_string,
			LOCAL.padding:rep(line_time_pad),
			time_string,
		}
		content[1] = components
	end

	info_line()

	return content
end

return M
