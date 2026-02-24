local require_safe = require("utils.require_safe")

local config = require_safe("utils.logger.config")

if not config then
	return
end

--- Validates if a given input is a valid number.
---@param arg string Given input of the user command.
---@return integer|nil number On success returns the number, otherwise nil.
local function validate_number(arg)
	local number = tonumber(arg, 10)
	if not number then
		error("Please provide a valid line number", vim.log.levels.ERROR)
		return nil
	end
	return number
end

--- Function to validate if the given number is a valid rotate file of the nvim logger.
---@param arg string The given number as string.
---@return string|nil name Log file to open
local function validate_log_number(arg)
	local name = config.config.name
	if arg ~= nil then
		local number = validate_number(arg)
		if number == nil then
			return
		end
		if config.config.files < number or number < 0 then
			error("Argument needs to be between 0 < ARG < " .. tostring(config.config.files), vim.log.levels.ERROR)
			return nil
		end
		name = config.config.name .. "-" .. arg
	end
	return name
end

--- Opens the logfile in a new tab
---@usage: :LOGOpen [N]   (Opens nvim-N.log in a new tabpage, default opens nvim.log)
vim.api.nvim_create_user_command("LOGOpen", function(opts)
	local name = validate_log_number(opts.fargs[1])
	if name then
		local file_name = string.format("%s/%s.log", config.config.path, name)
		vim.cmd("tabnew " .. file_name)
	end
end, { desc = "Open the nvim log file", nargs = "?" })

--- Uses `tail` to fetch the last line, extracts the message part,
--- prints it and copies it to the clipboard.
---@usage: :LOGLast [N]   (Prints last line from file nvim-N.log, default prints nvim.log)
vim.api.nvim_create_user_command("LOGLast", function(opts)
	local name = validate_log_number(opts.fargs[1])
	if name then
		local file_name = string.format("%s/%s.log", config.config.path, name)
		local last_line = vim.fn.system("tail -n 1 " .. vim.fn.shellescape(file_name)):gsub("\n$", "")
		local msg = last_line:match("| [A-Z]+ | (.*)")
		print(msg)
		vim.fn.setreg("+", msg)
	end
end, { desc = "Copy the last log message to the clipboard and print it.", nargs = "?" })

--- Function to extract given line number from the file
---@param file file* Handler of the file to read
---@param line_number integer Line to extract from file
---@return string|nil line Returns line on success otherwise nil
local function get_log_line(file, line_number)
	local cur = 0
	for line in file:lines() do
		cur = cur + 1
		if cur == line_number then
			return line
		end
	end
	return nil
end

--- Reads the log file sequentially until it reaches the requested line,
--- then prints and copies the message part.
---@usage: LOGLineN N [M] (Prints line N from file nvim-M.log, default prints N from file nvim.log)
vim.api.nvim_create_user_command("LOGLineN", function(opts)
	local args = opts.fargs
	if #args < 1 then
		error("At least one argument is required", vim.log.levels.ERROR)
		return
	end

	local line_number = validate_number(args[1])
	local name = validate_log_number(args[2])
	if line_number == nil or name == nil then
		return
	end

	local file_name = string.format("%s/%s.log", config.config.path, name)
	local file = io.open(file_name, "r")
	if not file then
		error("File does not exist or cannot be opened", vim.log.levels.ERROR)
		return
	end

	local line = get_log_line(file, line_number)
	file:close()

	if line == nil then
		error("Line does not exist in the given file", vim.log.levels.ERROR)
		return
	end

	local msg = line:match("| [A-Z]+ | (.*)")
	if msg then
		print(msg)
		vim.fn.setreg("+", msg)
	else
		vim.notify("Line format unexpected – could not extract message", vim.log.levels.WARN)
	end
end, { desc = "Copy the log message of line N to the clipboard and print it.", nargs = "*" })
