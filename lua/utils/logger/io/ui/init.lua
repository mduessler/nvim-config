local buffer = require("utils.logger.io.ui.buffer")
local segments = require("utils.logger.io.ui.segments")
local window = require("utils.logger.io.ui.window")

---
--- Interface for the logging.ui module.
---

local M = {}

--- Function to capsulate all functions to generate the ui
---@param msg string Logging message to display
---@param level string Logging level
---@param entry integer Line number of the entry in the logging file
M.show = function(msg, level, entry)
	local hl = "Logger" .. level
	local content = segments.create(msg, level, entry)
	local buf, height = buffer.create(content, hl)
	if buf ~= 0 then
		window.create(buf, height, hl)
	end
end

return M
