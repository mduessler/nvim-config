local config = require("utils.logger.config")

---
--- Helper function for the logging.ui.segments module
---

--- Function to build the components of the firstline.
---@param level string Logging level
---@param entry integer Linenumber of the entry in the log file
---@return table components Table of the first line components
local function build_first_line_components(level, entry)
	local level_str = config.signs[level:lower()] .. " " .. level
	local line_str = config.signs.line .. tostring(entry) .. " "
	local time_str = config.signs.time .. " " .. os.date("%H:%M:%S")

	local level_width = vim.fn.strdisplaywidth(level_str)
	local line_width = vim.fn.strdisplaywidth(line_str)
	local time_width = vim.fn.strdisplaywidth(time_str)
	local fixed_pad_after_line = 3

	local fixed_total = level_width + line_width + time_width + fixed_pad_after_line
	local dynamic_pad_width = config.width - fixed_total - 2 -- 2 = left + right padding

	local components = {
		config.signs.padding,
		level_str,
		config.signs.padding:rep(dynamic_pad_width),
		line_str,
		config.signs.padding:rep(fixed_pad_after_line),
		time_str,
		config.signs.padding,
	}
	return components
end

--- Function to generate from the logging message strings with a fixed size. Each string represents a line in the
--- buffer.
---@param msg string The logging message
---@return table lines
local function wrap_message(msg)
	local current_line = " "

	local lines = {}

	for word in string.gmatch(msg, "%S+") do
		local word_width = vim.fn.strdisplaywidth(word)

		if word_width > config.width then
			for i = 1, #word do
				local char = word:sub(i, i)
				local candidate = current_line .. char .. " "
				if vim.fn.strdisplaywidth(candidate) > config.width then
					table.insert(lines, current_line .. " ")
					current_line = " "
				end
				current_line = current_line .. char
			end
			current_line = current_line .. " "
		else
			local candidate = current_line .. word .. " "
			if vim.fn.strdisplaywidth(candidate) > config.width then
				table.insert(lines, current_line)
				current_line = " "
			end
			current_line = current_line .. word .. " "
		end
	end

	if current_line ~= " " then
		table.insert(lines, current_line)
	end

	return lines
end

---
--- Public functions of the logging.ui.segments module
---

local M = {}

--- Build the structured content for a log message.
--- The content is an array where:
---   [1] = table of components for the first line (level, line number, time)
---   [2] = divider string
---   [3..] = wrapped message lines (as strings)
---@param msg string The log message text
---@param level string Log level (e.g., "INFO", "ERROR")
---@param entry number Line number or identifier
---@return table content
M.create = function(msg, level, entry)
	local content = {}
	content[1] = build_first_line_components(level, entry)
	content[2] = config.divider

	local msg_lines = wrap_message(msg)
	for i = 1, #msg_lines do
		content[2 + i] = msg_lines[i]
	end

	return content
end

return M
