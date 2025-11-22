local require_safe = require("utils.require_safe")

local close_process = require_safe("core.ui.utils.async.close_process")
local close_timer = require_safe("core.ui.utils.async.close_timer")

if not (close_process and close_timer) then
	return
end

local function git_status(M)
	if M._running.status then
		return
	end

	close_process(M._handle.status)
	M._running.status = true

	M._handle.status = vim.loop.spawn("sh", {
		args = {
			"-c",
			'[ -n "$(git status --porcelain)" ] && exit 1 || exit 0',
		},
		cwd = M.cwd,
	}, function(code, _)
		M.modified = (code ~= 0)
		close_process(M._handle.status)
		M._running.status = false
	end)

	if not M._handle.status then
		M.modified = false
		M._running.status = false
	end
end

return git_status
