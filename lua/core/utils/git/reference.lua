local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

--- Function to get the named reference, if a commit hash exists.
---@param M table Module table of the git module
local function reference(M)
	if M._running.reference or M.commit.long == "" then
		return
	end

	close_process(M._handle.reference)
	M._running.reference = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.reference = vim.loop.spawn("git", {
		args = { "name-rev", "--name-only", M.commit.long },
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
			print("--")
			print(current_reference)
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
