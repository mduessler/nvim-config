local handler = vim.fn.stdpath("config") .. "/lua/utils/update/handler.lua"

vim.system({ "lua", handler }, { text = true }, function(result)
	vim.schedule(function()
		if result.code == 0 then
			vim.notify("Config is up to date", vim.log.levels.DEBUG)
		else
			vim.notify("New version available", vim.log.levels.SUCCESS)
		end
	end)
end)
