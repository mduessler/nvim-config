local require_safe = require("utils.require_safe")

local LOCAL = require_safe("utils.logger.config")

if not LOCAL then
	return
end

vim.api.nvim_create_user_command("OpenLog", function()
	local file_name = string.format("%s/%s.log", LOCAL.config.path, LOCAL.config.name)
	vim.cmd("tabnew " .. file_name)
end, { desc = "Open the nvim log file" })
