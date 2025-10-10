local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (str and signs) then
	return
end

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
