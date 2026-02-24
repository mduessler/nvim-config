local require_safe = require("utils.require_safe")

local config = require_safe("utils.logger.config")

if not config then
	return
end

local M = {}

--- Function to create a timestamp with ms from the current time.
---@return string timestamp
local function timestamp()
	local ms = vim.loop.now() % 1000
	return os.date("%Y-%m-%d--%H:%M:%S") .. string.format(".%03d", ms % 1000)
end

--- Function to verify file does not exceed the maximum size.
---@param file string Filename to check
---@return boolean|nil
local function log_is_larger_than_500MB(file)
	local stat = vim.loop.fs_stat(file)
	if not stat then
		error("Can not access file " .. file .. ".", vim.log.levels.ERROR)
		return nil
	end
	return stat.size > config.config.size * 1024 * 1024
end

--- Function to reset the meta file
---@param file string Name of the file which stores the meta data.
---@return boolean
local function reset_meta_handler(file)
	local meta_handler = io.open(file, "w")
	if meta_handler then
		meta_handler:close()
		return true
	end
	error("Could not reset meta counter", vim.log.levels.ERROR)
	return false
end

--- Function to rename and delete old log rotates and reset meta file.
---@param log_file string Name of the log file.
---@param meta_file string Name of the meta file.
local function rotate_log_file(log_file, meta_file)
	local rotate = string.format("%s/%s-%i.log", config.config.path, config.config.name, config.config.files)
	if vim.loop.fs_stat(rotate) then
		os.remove(rotate)
		reset_meta_handler(meta_file)
	end
	os.rename(log_file, rotate)
end

--- Function to get line counter from the meta file.
---@param file string Name of the meta file.
---@return integer linenumber
local function get_meta_line_counter(file)
	local handler = io.open(file, "r")
	if not handler then
		return 0
	end
	return tonumber(handler:read("*n"), 10)
end

--- Function to set the new meta line counter.
---@param entry integer Linenumber of the logging message in the metafile.
---@param file string Name of the meta file.
---@return boolean
local function set_meta_line_counter(entry, file)
	if not reset_meta_handler(file) then
		return false
	end
	local handler = io.open(file, "w")
	if not handler then
		error("Could set meta handler", vim.log.levels.ERROR)
		return false
	end

	handler:write(tostring(entry))
	handler:close()
	return true
end

--- Function to the line entry in the meta file.
---@param file string Name of the meta file.
---@return integer linenumber
local function update_meta_line_counter(file)
	local linenumber = get_meta_line_counter(file) + 1
	set_meta_line_counter(linenumber, file)

	return linenumber
end

M.write = function(msg, level)
	local log_file = string.format("%s/%s.log", config.config.path, config.config.name)
	local meta_file = string.format("%s/%s.meta", config.config.path, config.config.name)

	if log_is_larger_than_500MB(log_file) then
		rotate_log_file(log_file, meta_file)
	end

	local handler = io.open(log_file, "a")
	if handler then
		msg = msg:gsub("\n", "  ")
		handler:write(string.format("%s | %-6s| %s\n", timestamp(), level, msg))
		handler:close()
		return update_meta_line_counter(meta_file)
	end
	error("Can not open log file at " .. log_file .. ".", vim.log.levels.ERROR)
	return -1
end

return M
