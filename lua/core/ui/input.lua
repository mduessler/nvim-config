local require_safe = require("utils.require_safe")

local mode = require_safe("core.ui.utils.mode")
local str = require_safe("utils.str")
local window = require_safe("core.ui.windows.utils")

if not (mode and str and window) then
	return
end

local M = {
	start_icon = " ",
	max_window = 30,
}

local function float_config(default_value, prompt)
	return {
		relative = "cursor",
		row = -3,
		col = -1,
		width = math.max(M.max_window, #default_value + 10),
		height = 1,
		style = "minimal",
		border = "rounded",
		title = prompt or "",
	}
end

local function update_float_width(win, bufnr)
	local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
	local new_width = math.max(M.max_window, #line + 10)

	local config = vim.api.nvim_win_get_config(win)
	if config.width ~= new_width then
		config.width = new_width
		vim.schedule(function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_config(win, config)
			end
		end)
	end
end

local function handle_input(winid, original_mode, on_confirm, input)
	window.close(winid)
	if type(on_confirm) == "function" then
		on_confirm(input)
	end
	mode.restore(original_mode)
end

M.input = function(opts, on_confirm)
	local default = opts.default or ""
	local original_mode = vim.api.nvim_get_mode().mode

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "nofile"

	local win = vim.api.nvim_open_win(bufnr, true, float_config(default, opts.prompt))
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { default })
	vim.keymap.set("i", "<CR>", function()
		local line = vim.api.nvim_get_current_line()
		line = line:gsub("%s+", "")
		handle_input(win, original_mode, on_confirm, line)
	end, { buffer = bufnr, nowait = true })

	vim.keymap.set("i", "<Esc>", function()
		handle_input(win, original_mode, on_confirm)
	end, { buffer = bufnr, nowait = true })

	vim.cmd("startinsert")
	vim.api.nvim_win_set_cursor(win, { 1, #default })
	vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI" }, {
		buffer = bufnr,
		callback = function()
			local row, col = window.position(win)
			if col <= #M.start_icon then
				vim.api.nvim_win_set_cursor(win, { row, #M.start_icon })
			end
		end,
	})

	vim.api.nvim_create_autocmd("TextChangedI", {
		buffer = bufnr,
		callback = function()
			update_float_width(win, bufnr)
		end,
	})

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = bufnr,
		callback = function()
			handle_input(win, original_mode, on_confirm)
		end,
	})
end

return M
