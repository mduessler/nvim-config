local mode = require("core.ui.utils.mode")
local signs = require("config.signs")
local str = require("utils.str")

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
		separator = signs.ui.separator.left.upper,
		padding = signs.ui.padding,
	},
}

local M = {}

M.get = function()
	local current_mode = mode.get()
	if current_mode == "" or current_mode == nil then
		return { length = 0, component = "" }
	end

	local content = table.concat({ "", LOCAL.signs.icon, current_mode, LOCAL.signs.separator }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)

	return { length = length, component = str.highlight(LOCAL.hl[current_mode:lower()], content) }
end

return M
