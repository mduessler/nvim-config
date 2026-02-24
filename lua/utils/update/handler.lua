local require_safe = require("utils.require_safe")

local logger = require_safe("utils.logger")

if not logger then
	return
end

local handler = vim.fn.stdpath("config") .. "/lua/utils/update/checker.lua"

vim.system({ "lua", handler, vim.fn.stdpath("config") }, { text = true }, function(result)
	vim.schedule(function()
		if result.code == 0 then
			logger.info("Config is up to date")
		else
			logger.info("New version available. Use 'UpdateNVIMConfig' to update.")
		end
	end)
end)
