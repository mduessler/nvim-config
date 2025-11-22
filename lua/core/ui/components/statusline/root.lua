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
		dir = "StatuslineRootSeperator",
		file = "StatuslineRootSeperatorNoDir",
		modified = {
			is = "StatuslineRootSeperatorIsModified",
			_not = "StatuslineRootSeperatorNotModified",
		},
	},
	signs = {
		git = signs.git.icon,
		padding = signs.ui.padding,
		project = signs.system.directory.project,
		separator = signs.ui.separator.right.triangle,
	},
}

LOCAL.length = {
	separator = vim.fn.strdisplaywidth(LOCAL.signs.separator),
}

local M = {}

M.get = function(buf)
	if project.root == "" then
		return { length = 0, component = "" }
	end

	local path = buf and buf.file.path or ""
	if directory.is_subpath(path, project.root) then
		path = directory.get_subdir(path, project.root):gsub("/$", "")
	end

	local function get_separator_hl_group()
		if path == "" then
			if project.is_git_repo and project.git.branch then
				return project.git.modified and LOCAL.hl.modified.is or LOCAL.hl.modified._not
			else
				return LOCAL.hl.file
			end
		end
		return LOCAL.hl.dir
	end

	local _, root = project.root:match("^(.-)/([^/]+)/?$")
	if not root then
		root = project.root
	end

	local length, content
	if project.is_git_repo then
		content = table.concat({ "", LOCAL.signs.git, root, "" }, LOCAL.signs.padding)
		length = vim.fn.strdisplaywidth(content)
	else
		content = table.concat({ "", LOCAL.signs.project, root, "" }, LOCAL.signs.padding)
		length = vim.fn.strdisplaywidth(content)
	end

	return {
		length = length + LOCAL.length.separator,
		component = str.highlight("StatuslineRoot", content)
			.. str.highlight(get_separator_hl_group(), LOCAL.signs.separator),
	}
end

return M
