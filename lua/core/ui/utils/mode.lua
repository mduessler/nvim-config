local require_safe = require("utils.require_safe")

local colors = require_safe("core.colors")

if not colors then
	return
end

local M = {
	map = {
		n = { name = "NORMAL", color = colors.ui.statusline.mode.bg.normal },
		no = { name = "NORMAL", color = colors.ui.statusline.mode.bg.normal },
		i = { name = "INSERT", color = colors.ui.statusline.mode.bg.insert },
		ic = { name = "INSERT", color = colors.ui.statusline.mode.bg.insert },
		v = { name = "VISUAL", color = colors.ui.statusline.mode.bg.visual },
		[""] = { name = "VISUAL", color = colors.ui.statusline.mode.bg.visual },
		V = { name = "VISUAL", color = colors.ui.statusline.mode.bg.visual },
		s = { name = "SELECT", color = colors.ui.statusline.mode.bg.select },
		S = { name = "SELECT", color = colors.ui.statusline.mode.bg.select },
		c = { name = "CMD", color = colors.ui.statusline.mode.bg.cmd },
		cv = { name = "CMD", color = colors.ui.statusline.mode.bg.cmd },
		ce = { name = "CMD", color = colors.ui.statusline.mode.bg.cmd },
		R = { name = "REPLACE", color = colors.ui.statusline.mode.bg.replace },
		Rv = { name = "REPLACE", color = colors.ui.statusline.mode.bg.replace },
		r = { name = "REPLACE", color = colors.ui.statusline.mode.bg.replace },
		rm = { name = "PROMPT", color = colors.ui.statusline.mode.bg.prompt },
		["r?"] = { name = "PROMPT", color = colors.ui.statusline.mode.bg.prompt },
		["!"] = { name = "PROMPT", color = colors.ui.statusline.mode.bg.prompt },
		t = { name = "TERMINAL", color = colors.ui.statusline.mode.bg.terminal },
		nt = { name = "TERMINAL", color = colors.ui.statusline.mode.bg.terminal },
	},
}

M.get = function()
	return M.map[vim.api.nvim_get_mode().mode].name or "UNKOWN"
end

M.color = function()
	if M.map[vim.api.nvim_get_mode().mode] == nil then
		vim.notify(vim.api.nvim_get_mode().mode, vim.log.levels.ERROR)
	end
	return M.map[vim.api.nvim_get_mode().mode].color or colors.ui.statusline.mode.bg.normal
end

M.restore = function(old)
	if old == "i" then
		vim.cmd("startinsert")
	elseif old == "n" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	elseif old == "v" or old == "V" or old == "\22" then
		return M.restore("n")
	end
end

return M
