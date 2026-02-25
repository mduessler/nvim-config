local require_safe = require("utils.require_safe")

local close_process = require_safe("core.ui.utils.async.close_process")
local close_timer = require_safe("core.ui.utils.async.close_timer")

if not (close_process and close_timer) then
	return
end

local function commits_to_push(M)
	if M._running.commits_to_push then
		return
	end

	close_process(M._handle.commits_to_push)
	M._running.commits_to_push = true

	M._handle.commits_to_push = vim.loop.spawn("sh", {
		args = {
			"-c",
			"test $(git rev-list --count @{u}..HEAD) -gt 0",
		},
		cwd = M.cwd,
	}, function(code, _)
		M.commits_to_push = (code == 0)
		close_process(M._handle.commits_to_push)
		M._running.commits_to_push = false
	end)

	if not M._handle.commits_to_push then
		M.commits_to_push = false
		M._running.commits_to_push = false
	end
end

return commits_to_push
