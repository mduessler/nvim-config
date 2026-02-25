local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.ui.utils.async.close_stream")
local close_process = require_safe("core.ui.utils.async.close_process")
local handle_stream = require_safe("core.ui.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

local function branch(M)
	if M._running.branch then
		return
	end

	close_process(M._handle.branch)
	M._running.branch = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.branch = vim.loop.spawn("git", {
		args = { "rev-parse", "--abbrev-ref", "HEAD" },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.branch = nil
		else
			local current_branch = table.concat(output):match("^%s*(.-)%s*$")
			M.branch = current_branch ~= "" and current_branch or nil
		end

		close_process(M._handle.branch)
		M._running.branch = false
	end)

	if not M._handle.branch then
		M._running.branch = false
		M.branch = ""
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return branch
