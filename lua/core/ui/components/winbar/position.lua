local str = require("utils.str")

local M = {}

M.component = function(win)
	local position = win.position_str()
	return str.highlight("WinbarPosition", position)
end

return M
