local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end

local LOCAL = {
	width = 40,
	ns = {
		time = vim.api.nvim_create_namespace("LoggerTime"),
		divider = vim.api.nvim_create_namespace("LoggerDivider"),
		msg = vim.api.nvim_create_namespace("LoggerMsg"),
	},
	windows = {},
}

LOCAL.signs = {
	divider = string.rep("─", LOCAL.width),
}

local function logging_buffer(lines, hl)
	local function hl_buf_line(buf, ns, line, end_col, hl_group)
		local opts = {
			end_row = line - 1,
			end_col = end_col,
			hl_group = hl_group,
		}
		vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, opts)
	end

	local function set_buf_options(buf)
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].swapfile = false
		vim.bo[buf].buflisted = false
	end

	local buf = vim.api.nvim_create_buf(false, true)
	if buf == 0 then
		vim.notify("Can not create an temporary buffer for update message.", vim.log.levels.ERROR)
		return 1
	end

	vim.api.nvim_buf_set_lines(buf, 0, 0, true, lines)
	hl_buf_line(buf, LOCAL.ns.time, 1, #lines[1], "LoggerTime")
	hl_buf_line(buf, LOCAL.ns.divider, 2, #LOCAL.signs.divider, hl)
	for i = 3, #lines do
		hl_buf_line(buf, LOCAL.ns.divider, i, #lines[i], "LoggerMsg")
	end
	set_buf_options(buf)

	return buf, #lines
end

local function logging_window(buf, height, hl)
	local function create_opts()
		local function calc_position()
			return vim.o.columns - vim.o.columns * 0.01 - LOCAL.width
		end

		local function set_border()
			local border = {}
			for _, value in ipairs({ "╭", "─", "╮", "│", "╯", "─", "╰", "│" }) do
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

local function logging_lines(msg)
	local function parse_msg(lines)
		local line = " "
		for word in string.gmatch(msg, "%S+") do
			if vim.fn.strdisplaywidth(word) > LOCAL.width then
				for i = 1, #word do
					local c = word:sub(i, i)
					if vim.fn.strdisplaywidth(line .. c .. " ") > LOCAL.width then
						lines[#lines + 1] = line .. " "
						line = " "
					end
					line = line .. c
				end
				line = line .. " "
			else
				if vim.fn.strdisplaywidth(line .. word .. " ") > LOCAL.width then
					lines[#lines + 1] = line
					line = " "
				end
				line = line .. word .. " "
			end
		end

		if line ~= " " then
			lines[#lines + 1] = line
		end

		return lines
	end

	local function parse_time_string()
		local time = signs.ui.statusline.datetime.time .. " " .. os.date("%H:%M:%S")
		return " " .. time
	end

	local lines = { parse_time_string(), LOCAL.signs.divider }
	lines = parse_msg(lines)

	return lines
end

local function logger(msg, hl)
	local lines = logging_lines(msg)
	local buf, height = logging_buffer(lines, hl)
	logging_window(buf, height, hl)
end

local M = {
	debug = function(msg)
		logger(msg, "InformDEBUG")
	end,
	info = function(msg)
		logger(msg, "InformINFO")
	end,
	warn = function(msg)
		logger(msg, "InformWARN")
	end,
	error = function(msg)
		logger(msg, "InformERROR")
	end,
}

return M
