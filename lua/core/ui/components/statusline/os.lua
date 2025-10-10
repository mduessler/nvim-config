local require_safe = require("utils.require_safe")

local mode = require_safe("core.ui.utils.mode")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (mode and signs and str) then
	return
end

local LOCAL = {
	hl = {
		normal = "StatuslineModenormal",
		insert = "StatuslineModeinsert",
		visual = "StatuslineModevisual",
		select = "StatuslineModeselect",
		cmd = "StatuslineModecmd",
		replace = "StatuslineModereplace",
		terminal = "StatuslineModeterminal",
		prompt = "StatuslineModeprompt",
	},
	signs = {
		seperator = signs.ui.seperator.right.upper,
		padding = signs.ui.padding,
	},
}

LOCAL.content = {
	linux = table.concat(
		{ LOCAL.signs.seperator, signs.ui.statusline.os.linux, "Linux", LOCAL.signs.padding },
		LOCAL.signs.padding
	),
	mac = table.concat(
		{ LOCAL.signs.seperator, signs.ui.statusline.os.mac, "Mac", LOCAL.signs.padding },
		LOCAL.signs.padding
	),
	windows = table.concat(
		{ LOCAL.signs.seperator, signs.ui.statusline.os.windows, "Windows", LOCAL.signs.padding },
		LOCAL.signs.padding
	),
	unkown = table.concat(
		{ LOCAL.signs.seperator, signs.ui.statusline.os.unkown, "Unkown OS", LOCAL.signs.padding },
		LOCAL.signs.padding
	),
}

LOCAL.length = {
	linux = vim.fn.strdisplaywidth(LOCAL.content.linux),
	mac = vim.fn.strdisplaywidth(LOCAL.content.mac),
	windows = vim.fn.strdisplaywidth(LOCAL.content.windows),
	unkown = vim.fn.strdisplaywidth(LOCAL.content.unkown),
}

local M = {}

local function get_os()
	if vim.fn.has("mac") == 1 then
		return "mac"
	elseif vim.fn.has("unix") == 1 then
		return "linux"
	elseif vim.fn.has("win32") == 1 then
		return "windows"
	else
		return "unkown"
	end
end

M.get = function()
	local key = get_os()
	local current_mode = mode.get()
	return {
		length = LOCAL.length[key],
		component = str.highlight(LOCAL.hl[current_mode:lower() or "normal"], LOCAL.content[key]),
	}
end

return M
