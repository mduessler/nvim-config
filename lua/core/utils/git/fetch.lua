local require_safe = require("utils.require_safe")
local close_process = require_safe("core.utils.async.close_process")

if not close_process then
	return
end

--- Function to fetch a gien reference from the remote server.
---@param M table Module table of the git module
---@param ref string Reference to fetch from the remote
local function fetch(M, ref)
	if M._running.fetch then
		return
	end

	close_process(M._handle.fetch)
	M._running.fetch = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	M._handle.fetch = vim.loop.spawn("git", {
		args = { "fetch", ref },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		M.fetch = (code ~= 0)
		close_process(M._handle.fetch)
		M._running.fetch = false
	end)

	if not M._handle.fetch then
		M.modified = false
		M._running.fetch = false
	end
end

return fetch
