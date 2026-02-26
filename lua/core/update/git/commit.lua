local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

--- Function to get the long commit hash of the nvim-config.
---@param M table Module table of the update module.
local function long(M)
	if M.running.commit then
		return
	end

	close_process(M.handle.commit)
	M.running.commit = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M.handle.commit = vim.loop.spawn("sh", {
		args = { "-c", string.format("'cd %s && git rev-parse HEAD'", vim.fn.stdpath("config")) },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.commit = nil
		else
			local current_commit = table.concat(output):match("^%s*(.-)%s*$")
			M.commit = current_commit ~= "" and current_commit or nil
		end

		close_process(M.handle.commit)
		M.running.commit = false
	end)

	if not M.handle.commit then
		M.running.commit = false
		M.commit = nil
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return long
