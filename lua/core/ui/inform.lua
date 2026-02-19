local function create_buffer(msg)
	local buf = vim.api.nvim_create_buf(false, true)
	if buf == 0 then
		vim.notify("Can not create an temporary buffer for update message.", vim.log.levels.ERROR)
		return 1
	end
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, { msg })
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].buflisted = false
	return buf
end

local function calc_position(width)
	return vim.o.columns - vim.o.columns * 0.01 - width
end

local function create_information_window(buf, msg)
	local width = vim.fn.strdisplaywidth(msg)
	local opts = {
		relative = "editor",
		row = 2,
		col = calc_position(width),
		width = width,
		height = 1,
		focusable = false,
		mouse = false,
		border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
		noautocmd = true,
	}
	local win = vim.api.nvim_open_win(buf, false, opts)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].cursorline = false
	--
	-- vim.api.nvim_create_autocmd("WinClosed", {
	-- 	pattern = tostring(win),
	-- 	callback = function(_)
	-- 		if #vim.api.nvim_list_wins() == 1 then
	-- 			vim.cmd("quit!")
	-- 		end
	-- 	end,
	-- })
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
