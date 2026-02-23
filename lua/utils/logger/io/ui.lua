local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

local M = {}

local function create_buffer(content, hl)
	local lines = {}
	local function parse_lines()
		for _, value in ipairs(content) do
			if type(value) == "table" then
				lines[#lines + 1] = table.concat(value)
			else
				lines[#lines + 1] = value
			end
		end
	end

	local function hl_buf_line(buf, line, end_col, hl_group)
		local opts = {
			end_row = line - 1,
			end_col = end_col,
			hl_group = hl_group,
		}
		vim.api.nvim_buf_set_extmark(buf, LOCAL.ns, line - 1, 0, opts)
	end

	local function set_buf_options(buf)
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].swapfile = false
		vim.bo[buf].buflisted = false
	end

	local function hl_lines(buf)
		local end_col = #lines[1]
		hl_buf_line(buf, 1, end_col, "LoggerTime")
		end_col = end_col - #content[1][#content[1]]
		hl_buf_line(buf, 1, end_col, "LoggerLine")
		end_col = end_col - #content[1][#content[1] - 1] - #content[1][#content[1] - 1]
		hl_buf_line(buf, 1, end_col, hl)

		hl_buf_line(buf, 2, #LOCAL.signs.divider, hl)
		for i = 3, #content do
			hl_buf_line(buf, i, #content[i], "LoggerMsg")
		end
	end

	local buf = vim.api.nvim_create_buf(false, true)
	if buf == 0 then
		vim.notify("Can not create an temporary buffer for update message.", vim.log.levels.ERROR)
		return 1
	end

	parse_lines()
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, lines)
	hl_lines(buf)

	set_buf_options(buf)

	return buf, #content
end

local function create_window(buf, height, hl)
	local function create_opts()
		local function calc_position()
			return vim.o.columns - vim.o.columns * 0.01 - LOCAL.width
		end

		local function set_border()
			local border = {}
			for _, value in ipairs(LOCAL.signs.border) do
				border[#border + 1] = { value, hl }
			end
			return border
		end

		return {
			relative = "editor",
			row = 3,
			col = calc_position(),
			width = LOCAL.width,
			height = height,
			focusable = false,
			mouse = false,
			border = set_border(),
			noautocmd = true,
		}
	end

	local function set_close_timer(win)
		local timer = vim.loop.new_timer()
		timer:start(
			20000,
			0,
			vim.schedule_wrap(function()
				vim.api.nvim_win_close(win, true)
				LOCAL.windows[win] = nil
			end)
		)
	end

	local function set_window_options(win)
		vim.wo[win].number = false
		vim.wo[win].relativenumber = false
		vim.wo[win].cursorline = false
	end

	local opts = create_opts()
	local function reposition_other_logging_windows()
		for winid, value in pairs(LOCAL.windows) do
			if value ~= nil then
				local config = vim.api.nvim_win_get_config(winid)
				config.row = config.row + opts.height + 2
				vim.api.nvim_win_set_config(winid, config)
			end
		end
	end

	local win = vim.api.nvim_open_win(buf, false, opts)
	reposition_other_logging_windows()
	LOCAL.windows[win] = vim.api.nvim_win_get_height(win) + 2

	set_window_options(win)
	set_close_timer(win)
end

local function create_content(msg, level, entry)
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
			LOCAL.signs.padding,
			level_string,
			LOCAL.signs.padding:rep(LOCAL.width - (2 + level_width + line_width + line_time_pad + time_width)),
			line_string,
			LOCAL.signs.padding:rep(line_time_pad),
			time_string,
			LOCAL.signs.padding,
		}
		content[1] = components
	end

	local function create_msg_components()
		local line = " "
		for word in string.gmatch(msg, "%S+") do
			if vim.fn.strdisplaywidth(word) > LOCAL.width then
				for i = 1, #word do
					local c = word:sub(i, i)
					if vim.fn.strdisplaywidth(line .. c .. " ") > LOCAL.width then
						content[#content + 1] = line .. " "
						line = " "
					end
					line = line .. c
				end
				line = line .. " "
			else
				if vim.fn.strdisplaywidth(line .. word .. " ") > LOCAL.width then
					content[#content + 1] = line
					line = " "
				end
				line = line .. word .. " "
			end
		end

		if line ~= " " then
			content[#content + 1] = line
		end
	end

	info_line()
	content[2] = LOCAL.signs.divider
	create_msg_components()

	return content
end

M.show = function(msg, level, entry)
	local hl = "Logger" .. level
	local lines = create_content(msg, level, entry)
	local buf, height = create_buffer(lines, hl)
	create_window(buf, height, hl)
end

return M
