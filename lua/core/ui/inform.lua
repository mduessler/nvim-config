local function inform(msg, level)
	if level == nil then
		level = vim.log.levels.INFO
	end
	local buf = vim.api.nvim_create_buf(false, false)
	if buf == 0 then
		vim.notify("Can not create an temporary buffer for update message.", vim.log.levels.ERROR)
		return 1
	end
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, { msg })
	vim.bo[buf].bufhidden = "wipe"
	local width = vim.fn.strdisplaywidth(msg)
	local opts = {
		relative = "editor",
		row = 2,
		col = vim.api.nvim_win_get_width(0) - width,
		width = width,
		height = 1,
		focusable = false,
		mouse = false,
		border = "rounded",
	}
	local win = vim.api.nvim_open_win(buf, false, opts)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false

	local timer = vim.loop.new_timer()
	timer:start(
		5000,
		0,
		vim.schedule_wrap(function()
			vim.api.nvim_win_close(win, true)
		end)
	)
end

return inform
