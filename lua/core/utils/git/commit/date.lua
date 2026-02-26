local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

--- Function to get the commit date of the current active commit.
---@param M table Module table of the git module
local function date(M)
	if M._running.commit.date or M.commit.long == "" then
		return
	end

	close_process(M._handle.commit.date)
	M._running.commit.date = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.commit.date = vim.loop.spawn("git", {
		args = { "log", "-1", "--format=%at", M.commit.long },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.commit.date = nil
		else
			local current_unix = table.concat(output):match("(%d+)")
			M.commit.date = current_unix ~= "" and tonumber(current_unix) or nil
		end

		close_process(M._handle.commit.date)
		M._running.commit.date = false
	end)

	if not M._handle.commit.date then
		M._running.commit.date = false
		M.commit.date = nil
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return date
