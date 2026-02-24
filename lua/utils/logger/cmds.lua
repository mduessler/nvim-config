local require_safe = require("utils.require_safe")

local config = require_safe("utils.logger.config")

if not config then
	return
end

--- Opens the logfile in a new tab
vim.api.nvim_create_user_command("LOGOpen", function(opts)
	local arg = opts.args
	local name = config.config.name
	if arg ~= "" then
		local number = tonumber(arg, 10)
		if config.config.files < number or number < 0 then
			error("Argument needs to be between 0 < ARG < " .. tostring(config.config.files), vim.log.levels.ERROR)
			return
		end
		name = config.config.name .. "-" .. arg
	end
	local file_name = string.format("%s/%s.log", config.config.path, name)
	vim.cmd("tabnew " .. file_name)
end, { desc = "Open the nvim log file", nargs = "?" })

--- Uses `tail` to fetch the last line, extracts the message part,
--- prints it and copies it to the clipboard.
vim.api.nvim_create_user_command("LOGLast", function()
	local file_name = string.format("%s/%s.log", config.config.path, config.config.name)
	local last_line = vim.fn.system("tail -n 1 " .. vim.fn.shellescape(file_name)):gsub("\n$", "")
	local msg = last_line:match("| [A-Z]+ | (.*)")
	print(msg)
	vim.fn.setreg("+", msg)
end, { desc = "Copy the last log message to the clipboard and print it." })

--- Reads the log file sequentially until it reaches the requested line,
--- then prints and copies the message part.
vim.api.nvim_create_user_command("LOGLineN", function(opts)
	local number = tonumber(opts.args)
	if not number then
		error("Please provide a valid line number", vim.log.levels.ERROR)
		return
	end

	local file_name = string.format("%s/%s.log", config.config.path, config.config.name)
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
end, { desc = "Copy the last log message of line N to the clipboard and print it.", nargs = 1 })
