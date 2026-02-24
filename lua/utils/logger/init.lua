local require_safe = require("utils.require_safe")

local config = require_safe("utils.logger.config")
local cmds = require_safe("lua.utils.logger.cmds")
local file = require_safe("utils.logger.io.file")
local hl = require_safe("lua.utils.logger.highlights")
local levels = require_safe("utils.logger.levels")
local ui = require_safe("utils.logger.io.ui")

if not (config and cmds and file and hl and levels and ui) then
	return
end

local M = {}

---
--- Helper functions of the logging file.
---

--- Write a message to the log file and show it in a floating window.
---@param level string Log level (e.g., "DEBUG", "INFO")
---@param msg string The message to log
local function log(level, msg)
	if levels[config.level] <= levels[level] then
		local entry = file.write(msg, level)
		ui.show(msg, level, entry)
	end
end

---
--- Public functions of the logging module
---

--- Log a debug message.
---@param msg string The message
function M.debug(msg)
	log("DEBUG", msg)
end

--- Log an info message.
---@param msg string The message
function M.info(msg)
	log("INFO", msg)
end

--- Log a pass (success) message.
---@param msg string The message
function M.pass(msg)
	log("PASS", msg)
end

--- Log a warning message.
---@param msg string The message
function M.warn(msg)
	log("WARN", msg)
end

--- Log an error message.
---@param msg string The message
function M.error(msg)
	log("ERROR", msg)
end

--- Merge user settings into the global `LOCAL` configuration table.
--- Validates that every provided key exists in the default configuration.
---@param user_config table A table with configuration keys (e.g., {width=40, signs={...}})
---@usage M.setup({ width = 60, signs = { line = " " } })
function M.setup(user_config)
	for key, value in pairs(user_config) do
		if config[key] == nil and (not config.config or config.config[key] == nil) then
			error(string.format("Invalid configuration key: '%s'", key), vim.log.levels.ERROR)
		end
		if config.config and config.config[key] ~= nil then
			config.config[key] = value
		else
			if key == "width" then
				config.divider = string.rep(config.signs.divider, config.width)
			end
			config[key] = value
		end
	end
end

return M
