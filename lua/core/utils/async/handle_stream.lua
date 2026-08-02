local M = {}

M.stdout = function(stdout, output)
	stdout:read_start(function(err, chunk)
		if err then
			vim.schedule(function()
				vim.notify("Error reading from battery stdout: " .. tostring(err), vim.log.capacity.ERROR)
			end)
			return
		end
		if chunk then
			table.insert(output, chunk)
		end
	end)
end

M.stderr = function(stderr)
	stderr:read_start(function(err, chunk)
		if err then
			vim.schedule(function()
				vim.notify("Error reading from stderr: " .. tostring(err), vim.log.levels.ERROR)
			end)
			return
		end
		if chunk then
			vim.schedule(function()
				vim.notify("Stderr: " .. chunk, vim.log.levels.DEBUG)
			end)
		end
	end)
end

return M
