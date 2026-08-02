local windows = require("core.ui.windows.handler")
local signs = require("config.signs")
local str = require("utils.str")

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
