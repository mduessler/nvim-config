local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.ui.utils.async.close_stream")
local close_process = require_safe("core.ui.utils.async.close_process")
local handle_stream = require_safe("core.ui.utils.async.handle_stream")
local directory = require_safe("core.ui.utils.directory")

if not (close_stream and close_process and handle_stream and directory) then
	return
end

local function changes_in_file(M)
	if M._running.changes then
		return M._handle.changes
	end

	M._running.changes = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.changes = vim.loop.spawn("git", {
		args = { "diff", "--numstat" },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)
		if code == 0 then
			M.changes = {}
			for line in table.concat(output):gmatch("[^\r\n]+") do
				local added, deleted, filepath = line:match("^(%d+)%s+(%d+)%s+(.+)$")
				if added and deleted and filepath then
					M.changes[filepath] = {
						added = tonumber(added),
						deleted = tonumber(deleted),
					}
				end
			end
		end
		close_process(M._handle.changes)
		M._running.changes = false
	end)

	if not M._handle.changes then
		M._running.changes = false
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return changes_in_file
