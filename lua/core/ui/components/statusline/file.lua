local require_safe = require("utils.require_safe")

local colors = require_safe("core.colors")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (colors and signs and str) then
	return
end

local set_hl = vim.api.nvim_set_hl

local LOCAL = {
	signs = {
		padding = signs.ui.padding,
	},
}

LOCAL.length = {
	padding = vim.fn.strdisplaywidth(LOCAL.signs.padding),
}

local M = {}

M.get = function(buf)
	if not buf or not buf.file or not buf.file.name then
		return { length = 0, component = "" }
	end

	local fg = buf.file.color or colors.ui.fg

	set_hl(0, "StatuslineFile", { bg = colors.ui.statusline.bg, fg = fg })

	local content = table.concat({ "", buf.file.name, buf.file.icon, "" }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)

	return { length = length, component = str.highlight("StatuslineFile", content) }
end

return M
