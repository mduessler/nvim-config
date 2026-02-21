local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")
local cmds = require_safe("lua.utils.logger.cmds")
local file = require_safe("utils.logger.io.file")
local ui = require_safe("utils.logger.io.ui")

if not (LOCAL and cmds and file and ui) then
	return
end

local M = {
	debug = function(msg)
		ui.show(msg, "InformDEBUG")
		file.write(msg, "DEBUG")
	end,
	info = function(msg)
		ui.show(msg, "InformINFO")
		file.write(msg, "INFO")
	end,
	warn = function(msg)
		ui.show(msg, "InformWARN")
		file.write(msg, "WARN")
	end,
	error = function(msg)
		ui.show(msg, "InformERROR")
		file.write(msg, "ERROR")
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
