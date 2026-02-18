local handler = vim.fn.stdpath("config") .. "/lua/utils/update/checker.lua"

local function create_floating_window(msg)
	local buf = vim.api.nvim_create_buf(false, false)
	if buf == 0 then
		vim.notify("Can not create an temporary buffer for update message.", vim.log.levels.ERROR)
		return 1
	end
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, { msg })
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
end

vim.system({ "lua", handler, vim.fn.stdpath("config") }, { text = true }, function(ressult)
	vim.schedule(function()
		if ressult.code == 0 then
			create_floating_window("Config is up to date")
		else
			create_floating_window("New version available. Use 'UpdateNVIMConfig' to update.")
		end
	end)
end)
