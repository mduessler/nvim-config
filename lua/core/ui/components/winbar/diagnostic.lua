local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (str and signs) then
	return
end

local LOKAL = {
	hl = {
		error = "WinbarError",
		warning = "WinbarWarning",
		hint = "WinbarHint",
		info = "WinbarInfo",
	},
}
LOKAL.error = str.highlight(LOKAL.hl.error, signs.diagnostics.error)
LOKAL.warning = str.highlight(LOKAL.hl.warning, signs.diagnostics.warning)
LOKAL.hint = str.highlight(LOKAL.hl.hint, signs.diagnostics.hint)
LOKAL.info = str.highlight(LOKAL.hl.info, signs.diagnostics.info)
LOKAL.padding = str.highlight("WinbarPadding", signs.ui.padding)

local M = {}

M.component = function(win)
	local dias = {}
	local component = ""
	local buf = win.buf()
	if buf == nil then
		return ""
	end
	local function concat(key)
		if dias[key] ~= nil then
			if component ~= "" then
				component = component .. LOKAL.padding
			end
			component = component .. dias[key]
		end
	end
	for key, diagnositc in pairs(buf.diagnostics or {}) do
		if diagnositc.cnt > 0 then
			local cnt = tostring(diagnositc.cnt)
			dias[key] = str.highlight(LOKAL.hl[key], cnt) .. LOKAL.padding .. LOKAL[key]
		end
	end
	for _, value in ipairs({ "error", "warning", "hint", "info" }) do
		concat(value)
	end
	return component
end

return M
