local function create_buffer(msg)
	local buf = vim.api.nvim_create_buf(false, false)
	if buf == 0 then
		vim.notify("Can not create an temporary buffer for update message.", vim.log.levels.ERROR)
		return 1
	end
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, { msg })
	vim.bo[buf].bufhidden = "wipe"
	return buf
end

local function create_information_window(buf, msg)
	local width = vim.fn.strdisplaywidth(msg)
	local opts = {
		relative = "editor",
		row = 2,
		col = vim.api.nvim_win_get_width(0) - width,
		width = width,
		height = 1,
		focusable = false,
		mouse = false,
		border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
	}
	local win = vim.api.nvim_open_win(buf, false, opts)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
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
	local buf = create_buffer(msg)
	local win = create_information_window(buf, msg)
	close_window_after_x_seconds(win)
end

return inform
