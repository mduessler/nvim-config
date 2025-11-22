local require_safe = require("utils.require_safe")

local modified = require_safe("core.ui.utils.modified")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (modified and str and signs) then
	return
end

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
