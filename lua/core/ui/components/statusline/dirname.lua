local require_safe = require("utils.require_safe")

local directory = require_safe("core.ui.utils.directory")
local project = require_safe("core.ui.utils.project")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (directory and project and signs and str) then
	return
end

local LOCAL = {
	hl = {
		default = "StatuslineDirnameSeperator",
		is = "StatuslineDirnameSeperatorIsModified",
		_not = "StatuslineDirnameSeperatorNotModified",
	},
	signs = {
		icon = signs.system.directory.default,
		separator = signs.ui.separator.right.triangle,
		padding = signs.ui.padding,
	},
}

LOCAL.length = {
	separator = vim.fn.strdisplaywidth(LOCAL.signs.separator),
}

local M = {}

M.get = function(buf)
	if not buf or not buf.file or not buf.file.path then
		return { length = 0, component = "" }
	end

	local path = buf.file.path

	if directory.is_subpath(path, project.root) then
		path = directory.get_subdir(path, project.root):gsub("/$", "")
	end

	if path == "" then
		return { length = 0, component = "" }
	end

	local function get_hl_group()
		if project.is_git_repo then
			return project.git.modified and LOCAL.hl.is or LOCAL.hl._not
		end
		return LOCAL.hl.default
	end

	local content = table.concat({ "", LOCAL.signs.icon, path, "" }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)

	return {
		length = length + LOCAL.length.separator,
		component = str.highlight("StatuslineDirname", content .. str.highlight(get_hl_group(), LOCAL.signs.separator)),
	}
end

return M
