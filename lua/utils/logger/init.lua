local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")
local cmds = require_safe("lua.utils.logger.cmds")
local hl = require_safe("lua.utils.logger.highlights")
local file = require_safe("utils.logger.io.file")
local ui = require_safe("utils.logger.io.ui")

if not (LOCAL and cmds and hl and file and ui) then
	return
end

local M = {
	debug = function(msg)
		local entry = file.write(msg, "DEBUG")
		ui.show(msg, "DEBUG", entry)
	end,
	info = function(msg)
		local entry = file.write(msg, "INFO")
		ui.show(msg, "INFO", entry)
	end,
	pass = function(msg)
		local entry = file.write(msg, "PASS")
		ui.show(msg, "PASS", entry)
	end,
	warn = function(msg)
		local entry = file.write(msg, "WARN")
		ui.show(msg, "WARN", entry)
	end,
	error = function(msg)
		local entry = file.write(msg, "ERROR")
		ui.show(msg, "ERROR", entry)
	end,
}

M.setup = function(...)
	local args = { ... }
	for key, value in ipairs(args) do
		if key == "config" then
			for k, config in ipairs(value) do
				if config[k] == nil then
					error(string.format("The key %s does not exists in the table 'config'.", key))
				end
				LOCAL.config[k] = config
			end
		else
			if value[key] == nil then
				error(string.format("The key %s does not exists in the table.", key))
			end
			LOCAL[key] = value
		end
	end
end

return M
