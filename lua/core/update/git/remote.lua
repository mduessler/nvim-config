local require_safe = require("utils.require_safe")
local close_stream = require_safe("core.utils.async.close_stream")
local close_process = require_safe("core.utils.async.close_process")
local logger = require_safe("utils.logger")
local _handle_stream = require_safe("core.utils.async.handle_stream")

if not (close_stream and close_process and logger and _handle_stream) then
	return
end

--- Function to convert a iso string to unix time.
---@param iso_time string Iso time string.
local function iso_to_unix(iso_time)
	if #iso_time ~= 19 then
		logger.ERROR(string.format("Given iso time string is to low. Expected string length of 19, got %i", #iso_time))
		return nil
	end
	return os.time({
		year = iso_time:sub(1, 4),
		month = iso_time:sub(6, 7),
		day = iso_time:sub(9, 10),
		hour = iso_time:sub(12, 13),
		min = iso_time:sub(15, 16),
		sec = iso_time:sub(18, 19),
	})
end
--- Function to get the remote sha and date of the main branch.
---@param M table Module table of the git module
local function remote_branch(M)
	if M._running.commit.remote or M.commit.type ~= "branch" then
		return
	end

	close_process(M._handle.commit.remote)
	M._running.commit.remote = true

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local output = {}

	M._handle.commit.remote = vim.loop.spawn("sh", {
		args = {
			"-c",
			string.format(
				"curl %s/branches/main -s | jq '{commit: .commit.sha, date:.commit.commit.committer.date}'",
				M.remote_repo
			),
		},
		stdio = { nil, stdout, stderr },
		cwd = M.cwd,
	}, function(code, _)
		stdout:read_stop()
		stderr:read_stop()

		close_stream(stdout)
		close_stream(stderr)

		if code ~= 0 then
			M.commit.remote = nil
		else
			local commit, date = table.concat(output):match('"commit":%s*"([^"]+)".-"date":%s*"([^"]+)"')
			M.commit.remote.commit = commit ~= "" and commit or nil
			M.commit.remote.date = date ~= "" and iso_to_unix(date) or nil

			-- M.commit.remote = current_name ~= "" and current_name or nil
		end

		close_process(M._handle.commit.remote)
		M._running.commit.remote = false
	end)

	if not M._handle.commit.remote then
		M._running.commit.remote = false
		M.commit.remote = nil
		return
	end

	_handle_stream.stdout(stdout, output)
	_handle_stream.stderr(stderr)
end

return remote_branch
