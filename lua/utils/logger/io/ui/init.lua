local require_safe = require("utils.require_safe")

local buffer = require_safe("utils.logger.io.ui.buffer")
local segments = require_safe("utils.logger.io.ui.segments")
local window = require_safe("utils.logger.io.ui.window")

if not (buffer and segments and window) then
	return
end

local M = {}

M.show = function(msg, level, entry)
	local hl = "Logger" .. level
	local content = segments.create(msg, level, entry)
	local buf, height = buffer.create(content, hl)
	if buf ~= 0 then
		window.create(buf, height, hl)
	end
end

return M
