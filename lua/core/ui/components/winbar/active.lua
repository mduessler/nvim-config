local signs = require("config.signs")
local str = require("utils.str")

local icon = signs.ui.winbar.active
local padding = signs.ui.padding

local LOKAL = {
	length = vim.fn.strdisplaywidth(icon),
	icon = str.highlight("WinbarIconActive", icon),
}

LOKAL.padding = str.highlight("WinbarPadding", string.rep(padding, LOKAL.length * vim.fn.strdisplaywidth(padding)))

local M = {}

M.component = function(active)
	return active and LOKAL.icon or LOKAL.padding
end

return M
