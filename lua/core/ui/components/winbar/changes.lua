local require_safe = require("utils.require_safe")

local project = require_safe("core.ui.utils.project")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (project and str and signs) then
	return
end

local padding = signs.ui.padding

local LOKAL = {
	added = "WinbarAdd",
	deleted = "WinbarDel",
	padding = str.highlight("WinbarPadding", padding),
}

local M = {}

M.component = function(win)
	local buf = win.buf()
	if buf == nil or project.root == "" or not project.is_git_repo or buf.git.changes == nil then
		return ""
	end
	local component = ""

	local function concat(key)
		local part = signs.git.changes[key] .. buf.git.changes[key]
		component = component .. str.highlight(LOKAL[key], part)
	end

	if buf.git.changes.added ~= nil and buf.git.changes.added > 0 then
		concat("added")
	end
	if buf.git.changes.deleted ~= nil and buf.git.changes.deleted > 0 then
		if component ~= "" then
			component = component .. LOKAL.padding
		end
		concat("deleted")
	end

	return component
end

return M
