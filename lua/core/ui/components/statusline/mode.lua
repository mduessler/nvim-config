local require_safe = require("utils.require_safe")

local mode = require_safe("core.ui.utils.mode")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (mode and signs and str) then
	return
end

local LOCAL = {
	hl = {
		cmd = "StatuslineModecmd",
		insert = "StatuslineModeinsert",
		normal = "StatuslineModenormal",
		prompt = "StatuslineModeprompt",
		replace = "StatuslineModereplace",
		select = "StatuslineModeselect",
		terminal = "StatuslineModeterminal",
		visual = "StatuslineModevisual",
	},
	signs = {
		icon = signs.system.directory.nvim,
		seperator = signs.ui.seperator.left.upper,
		padding = signs.ui.padding,
	},
}

local M = {}

M.get = function()
	local current_mode = mode.get()
	if current_mode == "" or current_mode == nil then
		return { length = 0, component = "" }
	end

	local content = table.concat({ "", LOCAL.signs.icon, current_mode, LOCAL.signs.seperator }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)

	return { length = length, component = str.highlight(LOCAL.hl[current_mode:lower()], content) }
end

return M
