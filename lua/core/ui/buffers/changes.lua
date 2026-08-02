local project = require("core.ui.utils.project")
local dir = require("core.ui.utils.directory")

local M = {}

M.get = function(path, name)
	if not project.is_git_repo or not dir.is_subpath(path, project.root) then
		return nil
	end
	path = dir.get_subdir(path, project.root) .. name
	if project.git.changes[path] ~= nil then
		return project.git.changes[path]
	end
	return { added = 0, deleted = 0 }
end

return M
