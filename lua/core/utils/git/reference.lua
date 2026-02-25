local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

local function reference(M)
	if M._running.reference then
		return
	end

	close_process(M._handle.reference)
	M._running.reference = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.reference = vim.loop.spawn("git", {
		args = { "rev-parse", "--abbrev-ref", "HEAD" },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.reference = nil
		else
			local current_reference = table.concat(output):match("^%s*(.-)%s*$")
			M.reference = current_reference ~= "" and current_reference or nil
		end

		close_process(M._handle.reference)
		M._running.reference = false
	end)

	if not M._handle.reference then
		M._running.reference = false
		M.reference = ""
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return reference
