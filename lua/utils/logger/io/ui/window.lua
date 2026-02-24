local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

local M = {}

--- Clean up resources associated with a logger window.
---@param win integer Window ID
local function clean_window(win)
	if LOCAL.timers[win] then
		LOCAL.timers[win]:close()
		LOCAL.timers[win] = nil
	end
	LOCAL.windows[win] = nil
end

--- Set up a timer to auto‑close a window after X seconds.
---@param win integer Window ID
local function init_close_timer(win)
	LOCAL.timers[win] = vim.loop.new_timer()
	LOCAL.timers[win]:start(
		LOCAL.close,
		0,
		vim.schedule_wrap(function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			clean_window(win)
		end)
	)
end

--- Local window options.
---@param win integer Window ID
local function set_window_options(win)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].cursorline = false
end

--- Calculate the column position for the window.
---@return integer column
local function calc_position()
	return vim.o.columns - vim.o.columns * 0.01 - LOCAL.width
end

--- Build the border table using the configured signs and highlight.
---@param hl string Highlight group for the border
---@return table border
local function set_border(hl)
	local border = {}
	for _, value in ipairs(LOCAL.signs.border) do
		border[#border + 1] = { value, hl }
	end
	return border
end

--- Shift existing logger windows down to make room for a new one.
---@param new_win integer The newly created window
---@param shift_by integer Amount to shift each existing window down
local function reposition_other_logging_windows(new_win, shift_by)
	for winid, _ in pairs(LOCAL.windows) do
		if winid ~= new_win and vim.api.nvim_win_is_valid(winid) then
			local config = vim.api.nvim_win_get_config(winid)
			config.row = config.row + shift_by
			vim.api.nvim_win_set_config(winid, config)
		end
	end
end

--- Main function to create the logger window.
---@param buf integer Buffer handle
---@param height integer Window height
---@param hl string Highlight group of LoggingLevel, used by border and level
M.create = function(buf, height, hl)
	local opts = {
		relative = "editor",
		row = 3,
		col = calc_position(),
		width = LOCAL.width,
		height = height,
		focusable = false,
		mouse = false,
		border = set_border(hl),
		noautocmd = true,
	}

	local win = vim.api.nvim_open_win(buf, false, opts)
	if not win or win == 0 then
		vim.notify("Failed to create logger window", vim.log.levels.ERROR)
		return
	end

	local group = vim.api.nvim_create_augroup("LoggerWindow" .. win, { clear = true })
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win),
		group = group,
		callback = function()
			clean_window(win)
			pcall(vim.api.nvim_del_augroup_by_id, group)
		end,
	})

	local shift_amount = height + 2
	reposition_other_logging_windows(win, shift_amount)

	LOCAL.windows[win] = vim.api.nvim_win_get_height(win) + 2

	set_window_options(win)
	init_close_timer(win)
end

return M
