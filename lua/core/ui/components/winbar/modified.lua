local modified = require("core.ui.utils.modified")
local str = require("utils.str")

local LOCAL = {
	default = str.highlight("WinbarIsModified", modified.signs.default),
	readonly = str.highlight("WinbarIsReadonly", modified.signs.readonly),
}

local M = {}

M.component = function(win)
	local buf = win.buf()
	if not buf.modified.value or buf == nil then
		return ""
	end
	return modified.is_readonly() and LOCAL.readonly or LOCAL.default
end

return M
