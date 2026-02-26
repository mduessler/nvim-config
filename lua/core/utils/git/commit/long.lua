local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

local function long(M)
	if M._running.commit.long then
		return
	end

	close_process(M._handle.commit.long)
	M._running.commit.long = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.commit.long = vim.loop.spawn("git", {
		args = { "rev-parse", "HEAD" },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.commit.long = nil
		else
			local current_commit = table.concat(output):match("^%s*(.-)%s*$")
			M.commit.long = current_commit ~= "" and current_commit or nil
		end

		close_process(M._handle.commit.long)
		M._running.commit.long = false
	end)

	if not M._handle.commit.long then
		M._running.commit.long = false
		M.commit.long = nil
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return long
