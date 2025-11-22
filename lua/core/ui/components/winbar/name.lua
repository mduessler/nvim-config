local require_safe = require("utils.require_safe")

local directory = require_safe("core.ui.utils.directory")
local project = require_safe("core.ui.utils.project")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (str and project and directory and signs) then
	return
end

local LOKAL = {
	config = str.highlight("WinbarPathIconConfig", signs.system.directory.config),
	default = str.highlight("WinbarPathIconDefault", signs.system.directory.default),
	git = str.highlight("WinbarPathIconGit", signs.system.directory.git),
	home = str.highlight("WinbarPathIconHome", signs.system.directory.home),
	nvim = str.highlight("WinbarPathIconNvim", signs.system.directory.nvim),
	padding = str.highlight("WinbarPadding", signs.ui.padding),
	path = {
		home = os.getenv("HOME"),
	},
}

LOKAL.path.config = LOKAL.path.home .. "/.config"
LOKAL.path.nvim = LOKAL.path.config .. "/nvim"

local M = {}

local focus_button = function(win, name)
	local focus_fn_name = "WinbarFocusWindow" .. win.id
	_G[focus_fn_name] = function()
		if vim.api.nvim_win_is_valid(win.id) then
			vim.api.nvim_set_current_win(win.id)
		end
	end
	return string.format("%%@v:lua.%s@%s%%X", focus_fn_name, name)
end

M.component = function(win)
	local name = ""
	local sign = ""
	local buf = win.buf()
	if buf == nil then
		return ""
	end

	if directory.is_subpath(buf.file.path, LOKAL.path.nvim) then
		sign = LOKAL.nvim
		name = focus_button(win, directory.get_subdir(buf.file.path, LOKAL.path.nvim))
	elseif project.is_git_repo and directory.is_subpath(buf.file.path, project.root) then
		sign = LOKAL.git
		name = focus_button(win, directory.get_subdir(buf.file.path, project.root))
	elseif directory.is_subpath(buf.file.path, LOKAL.path.home) then
		if directory.is_subpath(buf.file.path, LOKAL.path.config) then
			sign = LOKAL.config
			name = focus_button(win, directory.get_subdir(buf.file.path, LOKAL.path.config))
		else
			sign = LOKAL.home
			name = focus_button(win, directory.get_subdir(buf.file.path, LOKAL.path.home))
		end
	else
		sign = LOKAL.default
		name = focus_button(win, buf.file.path)
	end

	return sign .. LOKAL.padding .. str.highlight("WinbarPath", name .. buf.file.name)
end

return M
