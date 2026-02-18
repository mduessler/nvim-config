local handler = vim.fn.stdpath("config") .. "/lua/utils/update/checker.lua"

vim.system({ "lua", handler, vim.fn.stdpath("config") }, { text = true }, function(ressult)
	vim.schedule(function()
		local inform = require("core.ui.inform")
		if ressult.code == 0 then
			inform("Config is up to date")
		else
			inform("New version available. Use 'UpdateNVIMConfig' to update.")
		end
	end)
end)
