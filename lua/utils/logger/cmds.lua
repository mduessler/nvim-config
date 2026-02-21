local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

vim.api.nvim_create_user_command("LOGOpen", function()
	local file_name = string.format("%s/%s.log", LOCAL.config.path, LOCAL.config.name)
	vim.cmd("tabnew " .. file_name)
end, { desc = "Open the nvim log file" })

vim.api.nvim_create_user_command("LOGLast", function()
	local file_name = string.format("%s/%s.log", LOCAL.config.path, LOCAL.config.name)
	local last_line = vim.fn.system("tail -n 1 " .. vim.fn.shellescape(file_name)):gsub("\n$", "")
	local msg = last_line:match("| [A-Z]+ | (.*)")
	print(msg)
	vim.fn.setreg("+", msg)
end, { desc = "Copy the last log message to the clipboard and print it." })

vim.api.nvim_create_user_command("LOGLineN", function(opts)
	local number = tonumber(opts.args)
	if not number then
		error("Please provide a valid line number", vim.log.levels.ERROR)
		return
	end

	local file_name = string.format("%s/%s.log", LOCAL.config.path, LOCAL.config.name)
	local file = io.open(file_name, "r")
	if file then
		local cur = 0
		for line in file:lines() do
			cur = cur + 1
			if cur == number then
				local msg = line:match("| [A-Z]+ | (.*)")
				print(msg)
				vim.fn.setreg("+", msg)
				file:close()
				return
			end
		end
	end
end, { desc = "Copy the last log message of line N to the clipboard and print it." })
