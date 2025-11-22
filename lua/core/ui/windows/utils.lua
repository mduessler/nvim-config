local M = {}

M.position = function(id)
	if vim.api.nvim_win_is_valid(id) then
		local cursor = vim.api.nvim_win_get_cursor(id)
		return cursor[1], cursor[2]
	end
	return 0, 0
end

M.close = function(id, force)
	if vim.api.nvim_win_is_valid(id) then
		vim.api.nvim_win_close(id, force or true)
	end
end

return M
