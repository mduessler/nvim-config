local require_safe = require("utils.require_safe")

local str = require_safe("utils.str")

if not str then
	return
end

local M = {}

M.component = function(win)
	local position = win.position_str()
	return str.highlight("WinbarPosition", position)
end

return M
