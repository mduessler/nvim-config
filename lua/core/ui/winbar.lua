local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")
local windows = require_safe("core.ui.windows.handler")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

local active = require_safe("core.ui.components.winbar.active")
local changes = require_safe("core.ui.components.winbar.changes")
local close_btn = require_safe("core.ui.components.winbar.close_button")
local diagnostic = require_safe("core.ui.components.winbar.diagnostic")
local modified = require_safe("core.ui.components.winbar.modified")
local name = require_safe("core.ui.components.winbar.name")
local position = require_safe("core.ui.components.winbar.position")

if
	not (
		buffers
		and windows
		and signs
		and str
		and active
		and changes
		and close_btn
		and diagnostic
		and modified
		and name
		and position
	)
then
	return
end

local LOKAL = {
	padding = str.highlight("WinbarPadding", signs.ui.padding),
	separator = {
		default = str.highlight("WinbarSeperator", signs.ui.separator.default),
		soft = str.highlight("WinbarSeperator", signs.ui.separator.left.soft_divider),
	},
}

local M = {}

local function render_winbar(win, is_active)
	if win.buf() == nil then
		return ""
	end
	local components = table.concat({ active.component(is_active), name.component(win) }, LOKAL.padding)
	local mod = modified.component(win)
	if mod ~= "" then
		components = table.concat({ components, mod }, LOKAL.padding)
	end
	components = table.concat({ components, LOKAL.separator.default, position.component(win) }, LOKAL.padding)
	local dia = diagnostic.component(win)
	local _changes = changes.component(win)
	if dia ~= "" or _changes ~= "" then
		components = table.concat({ components, LOKAL.separator.soft }, LOKAL.padding)
		if dia ~= "" and _changes ~= "" then
			components = table.concat({ components, dia, LOKAL.separator.default, _changes }, LOKAL.padding)
		elseif dia ~= "" then
			components = table.concat({ components, dia }, LOKAL.padding)
		else
			components = table.concat({ components, _changes }, LOKAL.padding)
		end
	end
	components = table.concat({ components, LOKAL.separator.default, close_btn.component(win), "" }, LOKAL.padding)

	return components
end

M.render = function()
	local bufnr = vim.api.nvim_get_current_buf()
	if not buffers.get(bufnr) then
		buffers.create(bufnr)
	end
	local win = windows.get(vim.api.nvim_get_current_win())

	if not win then
		return ""
	end

	return "%=" .. render_winbar(win, true)
end

M.setup = function()
	windows.create()
	vim.o.winbar = "%{%v:lua.require'core.ui.winbar'.render()%}"
end

M.update = function()
	for _, win in ipairs(windows.views) do
		if win ~= nil then
			if win.id ~= vim.api.nvim_get_current_win() and vim.api.nvim_win_is_valid(win.id) then
				vim.wo[win.id].winbar = "%=" .. render_winbar(win, false)
			else
				vim.o.winbar = "%{%v:lua.require'core.ui.winbar'.render()%}"
			end
		end
	end
end

return M
