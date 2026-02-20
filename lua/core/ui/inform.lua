local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end

local LOCAL = {
	width = 40,
	ns = { divider = vim.api.nvim_create_namespace("ns_divider_line") },
}

LOCAL.signs = {
	divider = string.rep("─", LOCAL.width),
}

local function create_buffer(lines, hl)
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
	hl_buf_line(buf, LOCAL.ns.divider, 2, #LOCAL.signs.divider, hl)
	set_buf_options(buf)

	return buf, #lines
end

local function create_information_window(buf, height, hl)
	local function opts()
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

	local function set_window_options(win)
		vim.wo[win].number = false
		vim.wo[win].relativenumber = false
		vim.wo[win].cursorline = false
	end

	local win = vim.api.nvim_open_win(buf, false, opts())
	set_window_options(win)

	return win
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

local function close_window_after_x_seconds(win)
	local timer = vim.loop.new_timer()
	timer:start(
		20000,
		0,
		vim.schedule_wrap(function()
			vim.api.nvim_win_close(win, true)
		end)
	)
end

local function create_buffer_lines(msg)
	local function parse_msg(lines)
		local line = " "
		for word in string.gmatch(msg, "%S+") do
			if vim.fn.strdisplaywidth(line .. word .. " ") > LOCAL.width then
				lines[#lines + 1] = line
				line = " "
			end
			line = line .. word .. " "
		end
		if line ~= " " then
			lines[#lines + 1] = line
		end
		return lines
	end

	local function parse_time_string()
		local time = signs.ui.statusline.datetime.time .. " " .. os.date("%H:%M:%S")
		return " " .. time
		-- return string.rep(" ", LOCAL.width - vim.fn.strdisplaywidth(time) - 1) .. time
	end

	local lines = { parse_time_string(), LOCAL.signs.divider }
	lines = parse_msg(lines)

	return lines
end

local function logger(msg, level)
	if level == nil then
		level = vim.log.levels.INFO
	end
	local hl = get_hl(level)
	local lines = create_buffer_lines(msg)
	local buf, height = create_buffer(lines, hl)
	local win = create_information_window(buf, height, hl)
	close_window_after_x_seconds(win)
end

return logger
