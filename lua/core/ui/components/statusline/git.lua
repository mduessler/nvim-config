local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")
local project = require_safe("core.ui.utils.project")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (buffers and project and signs and str) then
	return
end

local LOCAL = {
	hl = {
		is = {
			content = "StatuslineBranchIsModified",
			separator = "StatuslineBranchIsModifiedSeperator",
		},
		_not = {
			content = "StatuslineBranchNotModified",
			separator = "StatuslineBranchNotModifiedSeperator",
		},
	},
	signs = {
		branch = signs.git.branch,
		changes = {
			added = signs.git.changes.added,
			deleted = signs.git.changes.deleted,
		},
		padding = signs.ui.padding,
		pull = signs.git.pull,
		push = signs.git.push,
		pushpull = signs.git.pushpull,
		separator = signs.ui.separator.right.triangle,
	},
}

LOCAL.length = {
	separator = vim.fn.strdisplaywidth(LOCAL.signs.separator),
}

local M = {}

M.get = function()
	if not project.is_git_repo or not project.git.branch or project.git.branch == "" then
		return { length = 0, component = "" }
	end

	local content = table.concat({ "", LOCAL.signs.branch, project.git.branch }, LOCAL.signs.padding)

	local function update_sync_status()
		if project.git.commits_to_pull and project.git.commits_to_push then
			content = table.concat({ content, LOCAL.signs.pushpull }, LOCAL.signs.padding)
		elseif project.git.commits_to_pull then
			content = table.concat({ content, LOCAL.signs.pull }, LOCAL.signs.padding)
		elseif project.git.commits_to_push then
			content = table.concat({ content, LOCAL.signs.push }, LOCAL.signs.padding)
		end
	end
	local function update_changes()
		local added, deleted = 0, 0
		for _, file in pairs(project.git.changes) do
			if file then
				added = added + (file.added or 0)
				deleted = deleted + (file.deleted or 0)
			end
		end
		if added == 0 and deleted == 0 then
			return
		end

		content = content .. LOCAL.signs.padding

		if added > 0 then
			local add = table.concat({ LOCAL.signs.changes.added, tostring(added) })
			content = table.concat({ content, add }, LOCAL.signs.padding)
		end

		if deleted > 0 then
			local delete = table.concat({ LOCAL.signs.changes.deleted, tostring(deleted) })
			content = table.concat({ content, delete }, LOCAL.signs.padding)
		end
	end

	update_sync_status()
	local hl_group = project.git.modified and LOCAL.hl.is or LOCAL.hl._not

	if project.git.changes then
		update_changes()
	end

	return {
		length = vim.fn.strdisplaywidth(content) + LOCAL.length.separator,
		component = str.highlight(hl_group.content, content .. LOCAL.signs.padding)
			.. str.highlight(hl_group.separator, LOCAL.signs.separator),
	}
end

return M
