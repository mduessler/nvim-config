local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

local function short(M)
	if M._running.commit.short then
		return
	end

	close_process(M._handle.commit.short)
	M._running.commit.short = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.commit.short = vim.loop.spawn("git", {
		args = { "rev-parse", "HEAD" },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.commit.short = nil
		else
			local current_commit = table.concat(output):match("^%s*(.-)%s*$")
			M.commit.short = current_commit ~= "" and current_commit or nil
		end

		close_process(M._handle.commit.short)
		M._running.commit.short = false
	end)

	if not M._handle.commit.short then
		M._running.commit.short = false
		M.commit.short = ""
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return short
