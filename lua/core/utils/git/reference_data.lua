local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

--- Function to get the commit date of the given reference.
---@param M table Module table of the git module
---@param ref string Reference name of the commit
local function reference_date(M, ref)
	if M._running.reference_date then
		return
	end

	close_process(M._handle.reference_date)
	M._running.reference_date = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.reference_date = vim.loop.spawn("git", {
		args = { "log", "-1", "--format=%at", ref },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.reference_date = nil
		else
			local current_reference_date = table.concat(output):match("(%d+)")
			M.reference_date = current_reference_date ~= "" and tonumber(current_reference_date) or nil
		end

		close_process(M._handle.reference_date)
		M._running.reference_date = false
	end)

	if not M._handle.reference_date then
		M._running.reference_date = false
		M.reference_date = ""
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return reference_date
