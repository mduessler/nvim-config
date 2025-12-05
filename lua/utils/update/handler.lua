local handler = vim.fn.stdpath("config") .. "/lua/utils/update/checker.lua"

vim.system({ "lua", handler, vim.fn.stdpath("config") }, { text = true }, function(ressult)
	vim.schedule(function()
		if ressult.code == 0 then
			vim.notify("Config is up to date", vim.log.levels.INFO)
		else
			vim.notify("New version available", vim.log.levels.INFO)
		end
	end)
end)
