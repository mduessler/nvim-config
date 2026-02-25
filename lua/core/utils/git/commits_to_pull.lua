local require_safe = require("utils.require_safe")

local close_process = require_safe("core.ui.utils.async.close_process")
local close_timer = require_safe("core.ui.utils.async.close_timer")

if not (close_process and close_timer) then
	return
end

local function commits_to_pull(M)
	if M._running.commits_to_pull then
		return
	end

	close_process(M._handle.commits_to_pull)
	M._running.commits_to_pull = true

	M._handle.commits_to_pull = vim.loop.spawn("sh", {
		args = {
			"-c",
			"test $(git rev-list --count HEAD..@{u}) -gt 0",
		},
		cwd = M.cwd,
	}, function(code, _)
		M.commits_to_pull = (code == 0)
		close_process(M._handle.commits_to_pull)
		M._running.commits_to_pull = false
	end)

	if not M._handle.commits_to_pull then
		M.commits_to_pull = false
		M._running.commits_to_pull = false
	end
end

return commits_to_pull
