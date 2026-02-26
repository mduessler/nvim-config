local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

local function ls_remote(M)
	if M._running.ls_remote then
		return
	end

	close_process(M._handle.ls_remote)
	M._running.ls_remote = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.ls_remote = vim.loop.spawn("git", {
		args = { "ls-remote", "origin", "refs/heads/main", "'refs/tags/*'" },
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.references = {}
		else
			local current_ls_remote = table.concat(output):match("^%s*(.-)%s*$")
			current_ls_remote:gsub("(%S+)%s+refs/([^%s]+)", function(hash, ref)
				M.references[ref] = hash
			end)
		end

		close_process(M._handle.ls_remote)
		M._running.ls_remote = false
	end)

	if not M._handle.ls_remote then
		M._running.ls_remote = false
		M.references = {}
		return
	end

	handle_stream.stdout(stdout, output)
	handle_stream.stderr(stderr)
end

return ls_remote()
