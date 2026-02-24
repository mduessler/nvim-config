local require_safe = require("utils.require_safe")

local config = require_safe("utils.logger.config")

if not config then
	return
end

local M = {}

M.write = function(msg, level)
	local file_name = string.format("%s/%s.log", config.config.path, config.config.name)
	local meta_file = string.format("%s/%s.meta", config.config.path, config.config.name)

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
		return stat.size > config.config.size * 1024 * 1024
	end

	local function reset_meta_handler()
		local meta_handler = io.open(meta_file, "w")
		if meta_handler then
			meta_handler:close()
			return true
		end
		error("Could not reset meta counter", vim.log.levels.ERROR)
		return false
	end

	local function update_meta_line_counter()
		local function get_meta_line_counter()
			local meta_handler = io.open(meta_file, "r")
			if not meta_handler then
				return 0
			end
			return tonumber(meta_handler:read("*n"))
		end

		local function set_meta_line_counter(counter)
			if not reset_meta_handler() then
				return false
			end
			local meta_handler = io.open(meta_file, "w")
			if not meta_handler then
				error("Could set meta handler", vim.log.levels.ERROR)
				return false
			end

			meta_handler:write(tostring(counter))
			meta_handler:close()
			return true
		end

		local counter = get_meta_line_counter() + 1
		set_meta_line_counter(counter)

		return counter
	end

	local function rotate_log_file()
		local rotate = string.format("%s/%s-2.log", config.config.path, config.config.name)
		if vim.loop.fs_stat(rotate) then
			os.remove(rotate)
			reset_meta_handler()
		end
		os.rename(file_name, rotate)
	end

	if log_is_larger_than_500MB() then
		rotate_log_file()
	end

	local handler = io.open(file_name, "a")
	if handler then
		msg = msg:gsub("\n", "  ")
		handler:write(string.format("%s | %-6s| %s\n", timestamp(), level, msg))
		handler:close()
		return update_meta_line_counter()
	end
	error("Can not open log file at " .. file_name .. ".", vim.log.levels.ERROR)
	return -1
end

return M
