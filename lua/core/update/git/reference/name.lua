local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

--- Function to get the named reference, if a commit hash exists.
---@param M table Module table of the git module
local function name(M)
	if M.running.reference.name or M.commit.long == "" then
		return
	end

	close_process(M.handle.reference.name)
	M.running.reference.name = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M.handle.reference.name = vim.loop.spawn("sh", {
		args = { "-c", string.format("cd %s && 'name-rev --name-only %s'", vim.fn.stdpath("config"), M.commit.long) },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.reference.name = nil
		else
			local current_name = table.concat(output):match("^%s*(.-)%s*$")
			M.reference.name = current_name ~= "" and current_name or nil
		end

		close_process(M.handle.reference.name)
		M.running.reference.name = false
	end)

	if not M.handle.reference.name then
		M.running.reference.name = false
		M.reference.name = nil
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return name
