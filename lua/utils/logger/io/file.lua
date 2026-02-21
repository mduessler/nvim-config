local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

local M = {}

M.write = function(msg, level)
	local file_name = string.format("%s/%s.log", LOCAL.config.path, LOCAL.config.name)

	local function timestamp()
		local ms = vim.loop.now() % 1000
		return os.date("%Y-%m-%d--%H:%M:%S") .. string.format(".%03d", ms % 1000)
	end

	local function log_is_larger_than_500MB()
		local stat = vim.loop.fs_stat(file_name)
		if not stat then
			error("Can not access file " .. file_name .. ".", vim.log.levels.ERROR)
			return nil
		end
		return stat.size > LOCAL.config.size * 1024 * 1024
	end

	local function rotate_log_file()
		local rotate = string.format("%s/%s-2.log", LOCAL.config.path, LOCAL.config.name)
		if vim.loop.fs_stat(rotate) then
			os.remove(rotate)
		end
		os.rename(file_name, rotate)
	end

	if log_is_larger_than_500MB() then
		rotate_log_file()
	end

	local handler = io.open(file_name, "a")
	if handler then
		handler:write(string.format("%s | %-6s| %s\n", timestamp(), level, msg))
		handler:close()
		return
	end
	error("Can not open log file at " .. file_name .. ".", vim.log.levels.ERROR)
end

return M
