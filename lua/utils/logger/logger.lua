local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

local M = {}

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
