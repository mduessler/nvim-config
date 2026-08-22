local close_process = require("core.utils.async.close_process")

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
