local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end

local function parse_time_string(width)
	local time = signs.ui.statusline.datetime.time .. " " .. os.date("%H:%M:%S")
	return string.rep(" ", width - vim.fn.strdisplaywidth(time) - 1) .. time
end

local function create_buffer(msg, width)
	local buf = vim.api.nvim_create_buf(false, true)
	if buf == 0 then
		vim.notify("Can not create an temporary buffer for update message.", vim.log.levels.ERROR)
		return 1
	end
	local content = { parse_time_string(width), string.rep("─", width), " " .. msg .. " " }
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, content)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].buflisted = false
	return buf
end

local function calc_position(width)
	return vim.o.columns - vim.o.columns * 0.01 - width
end

local function get_hl(level)
	if level == vim.log.levels.DEBUG then
		return "InformDEBUG"
	elseif level == vim.log.levels.INFO then
		return "InformINFO"
	elseif level == vim.log.levels.WARN then
		return "InformWARN"
	elseif level == vim.log.levels.ERROR then
		return "InformERROR"
	else
		return "InformDefault"
	end
end

local function set_border(level)
	local hl = get_hl(level)
	local border = {}
	for _, value in ipairs({ "╭", "─", "╮", "│", "╯", "─", "╰", "│" }) do
		border[#border + 1] = { value, hl }
	end
	return border
end

local function create_information_window(buf, width, level)
	local opts = {
		relative = "editor",
		row = 2,
		col = calc_position(width),
		width = width,
		height = 3,
		focusable = false,
		mouse = false,
		border = set_border(level),
		noautocmd = true,
	}
	local win = vim.api.nvim_open_win(buf, false, opts)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].cursorline = false
	return win
end

local function close_window_after_x_seconds(win)
	local timer = vim.loop.new_timer()
	timer:start(
		5000,
		0,
		vim.schedule_wrap(function()
			vim.api.nvim_win_close(win, true)
		end)
	)
end

local function inform(msg, level)
	if level == nil then
		level = vim.log.levels.INFO
	end
	local width = vim.fn.strdisplaywidth(msg) + 2
	local buf = create_buffer(msg, width)
	local win = create_information_window(buf, width, level)
	close_window_after_x_seconds(win)
end

return inform
