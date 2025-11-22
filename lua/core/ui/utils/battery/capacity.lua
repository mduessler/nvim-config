local require_safe = require("utils.require_safe")

local close_stream = require_safe("core.ui.utils.async.close_stream")
local close_process = require_safe("core.ui.utils.async.close_process")
local handle_stream = require_safe("core.ui.utils.async.handle_stream")

if not (close_stream and close_process and handle_stream) then
	return
end

local function run(M)
	if M._running.capacity then
		return
	end

	for _, item in ipairs(M.pathes) do
		close_process(M._capacity_handle)
		M._running.capacity = true

		local stdout = vim.loop.new_pipe(false)
		local stderr = vim.loop.new_pipe(false)
		local output = {}

		M._capacity_handle = vim.loop.spawn("cat", {
			args = { item.path .. "/capacity" },
			stdio = { nil, stdout, stderr },
		}, function(code)
			stdout:read_stop()
			stderr:read_stop()

			close_stream(stdout)
			close_stream(stderr)

			if code ~= 0 then
				M.capacities[item.name] = nil
			else
				M.capacities[item.name] = tonumber(table.concat(output):match("(%d+)"))
			end

			close_process(M._capacity_handle)
			M._running.capacity = false
		end)

		if not M._capacity_handle then
			M._running.capacity = false
			return
		end

		handle_stream.stdout(stdout, output)
		handle_stream.stderr(stderr)
	end
end

return run
