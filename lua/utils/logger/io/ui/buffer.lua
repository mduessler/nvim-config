local config = require("utils.logger.config")

---
--- Helper function for the logging.ui.buffer module
---

--- Flatten line.
--- @param segment string|table
--- @return string
local function flatten(segment)
	if type(segment) == "table" then
		return table.concat(segment)
	end
	return segment
end

--- Parse the segments of a line into a list of lines.
--- @param segments table Array of strings or tables of strings
--- @return table Array of strings (lines)
local function parse_lines(segments)
	local lines = {}
	for _, value in ipairs(segments) do
		lines[#lines + 1] = flatten(value)
	end
	return lines
end

--- Apply a highlight to a range in a buffer line.
--- @param buf integer Buffer ID
--- @param line integer Line number (1‑based)
--- @param start_col integer Start column (0‑based)
--- @param end_col integer End column (exclusive, i.e. last column + 1)
--- @param hl_group string Highlight group name
local function hl_buf_line(buf, line, start_col, end_col, hl_group)
	local opts = {
		end_row = line - 1,
		end_col = end_col,
		hl_group = hl_group,
	}
	vim.api.nvim_buf_set_extmark(buf, config.ns, line - 1, start_col, opts)
end

--- Local Buffer options.
--- @param buf integer Buffer ID
local function set_buf_options(buf)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].buflisted = false
end

--- Highlight the first line of the log buffer, which contains level, line number, and time.
--- @param buf integer Buffer ID
--- @param segments table Array of strings (the six components of the first line)
--- @param main_hl string Highlight group for the level part (e.g., "LoggerINFO")
local function hl_first_line(buf, segments, main_hl)
	local level_start = #segments[1]
	local level_end = level_start + #segments[2]
	hl_buf_line(buf, 1, level_start, level_end, main_hl)

	local line_start = level_end + #segments[3]
	local line_end = line_start + #segments[4]
	hl_buf_line(buf, 1, line_start, line_end, "LoggerLine")

	local time_start = line_end + #segments[5]
	local time_end = time_start + #segments[6]
	hl_buf_line(buf, 1, time_start, time_end, "LoggerTime")
end

--- Highlight all message lines (from line 3 onward) with "LoggerMsg".
--- @param buf integer Buffer ID
--- @param segments table Array of raw segments items (strings or tables)
local function hl_message_lines(buf, segments)
	for i = 3, #segments do
		local line_str = flatten(segments[i])
		hl_buf_line(buf, i, 0, #line_str, "LoggerMsg")
	end
end

---
--- Public functions of the logging.ui.buffer module
---

local M = {}

--- Create a buffer for the logger.
--- @param segments table Structured log segments (see create_segments)
--- @param hl string Main highlight group for the level part
--- @return integer buf Buffer ID (0 if creation failed)
--- @return integer height Number of lines in the buffer
M.create = function(segments, hl)
	local buf = vim.api.nvim_create_buf(false, true)
	if buf == 0 then
		vim.notify("Cannot create a temporary buffer for the log message.", vim.log.levels.ERROR)
		return 0, 0
	end

	local lines = parse_lines(segments)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

	if type(segments[1]) == "table" then
		hl_first_line(buf, segments[1], hl)
	else
		hl_buf_line(buf, 1, 0, #lines[1], hl)
	end
	hl_buf_line(buf, 2, 0, #config.divider, hl)
	hl_message_lines(buf, segments)

	set_buf_options(buf)

	return buf, #segments
end

return M
