local M = {}

M.detect = function()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.filetype.match({ buf = buf })
	if not ft then
		vim.notify("No filetype detected for this buffer", vim.log.levels.WARN)
		return
	end
	vim.bo[buf].filetype = ft
	vim.notify(("Filetype set to '%s'"):format(ft))
end

M.setup = function()
	vim.api.nvim_create_user_command("DetectFiletype", M.detect, {
		desc = "Detect the filetype from the buffer content and start the matching tools",
	})
end

return M
