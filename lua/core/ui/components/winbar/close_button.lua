local require_safe = require("utils.require_safe")

local windows = require_safe("core.ui.windows.handler")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (str and windows and signs) then
	return
end

local sign = signs.quit.icon

local LOKAL = {
	sign = str.highlight("WinbarClose", sign),
}

local M = {}

M.component = function(win)
	local close_fn_name = "WinbarCloseWindow" .. win.id
	_G[close_fn_name] = function()
		windows.delete(win.id)
		if #windows.views == 0 then
			vim.cmd("qa")
		end
		vim.api.nvim_win_close(win.id, false)
	end
	local component = string.format("%%@v:lua.%s@%s%%X", close_fn_name, LOKAL.sign)
	return component
end

return M
