local require_safe = require("utils.require_safe")

local window = require_safe("core.ui.windows.window")

if not window then
	return
end

local M = { views = {} }

vim.api.nvim_create_autocmd("WinNew", {
	callback = function()
		M.create()
	end,
})

vim.api.nvim_create_autocmd("WinClosed", {
	callback = function(args)
		local closed_winid = tonumber(args.match)
		if closed_winid then
			M.delete(closed_winid)
		end
	end,
})

M.create = function()
	local winid = vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(winid) then
		return
	end
	local new = window(winid)
	table.insert(M.views, new)
end

M.delete = function(winid)
	_G["WinbarCloseWindow" .. winid] = nil
	_G["WinbarFocusWindow" .. winid] = nil
	for i, win in ipairs(M.views) do
		if win.id == winid then
			table.remove(M.views, i)
			break
		end
	end
end

M.get = function(winid)
	for _, win in ipairs(M.views) do
		if win.id == winid then
			return win
		end
	end
	return nil
end

return M
