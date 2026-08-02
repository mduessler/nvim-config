local close_stream = require("core.utils.async.close_stream")
local close_process = require("core.utils.async.close_process")
local handle_stream = require("core.utils.async.handle_stream")

local function run(M)
	if M._running.state then
		return
	end

	for _, item in ipairs(M.pathes) do
		close_process(M._state_handle)
		M._running.state = true

		local stdout = vim.loop.new_pipe(false)
		local stderr = vim.loop.new_pipe(false)
		local output = {}

		M._state_handle = vim.loop.spawn("cat", {
			args = { item.path .. "/status" },
			stdio = { nil, stdout, stderr },
		}, function(code)
			stdout:read_stop()
			stderr:read_stop()

			close_stream(stdout)
			close_stream(stderr)

			if code ~= 0 then
				M.states[item.name] = nil
			else
				M.states[item.name] = table.concat(output):match("^%s*([^,]-)%s*,?%s*$")
			end

			close_process(M._state_handle)
			M._running.state = false
		end)

		if not M._state_handle then
			M._running.state = false
			return
		end

		handle_stream.stdout(stdout, output)
		handle_stream.stderr(stderr)
	end
end

return run
