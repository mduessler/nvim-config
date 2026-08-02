local M = {}

local delimiters = '[%s":%-]'

local function token_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	if line == "" or col > #line or line:sub(col, col):match(delimiters) then
		return nil
	end
	local start = col
	while start > 1 and not line:sub(start - 1, start - 1):match(delimiters) do
		start = start - 1
	end
	local stop = col
	while stop < #line and not line:sub(stop + 1, stop + 1):match(delimiters) do
		stop = stop + 1
	end
	return line:sub(start, stop), start, stop
end

local function is_readable(text)
	return not text:find("[%z\1-\8\11\12\14-\31]")
end

M.decode = function()
	local token, start, stop = token_under_cursor()
	if not token then
		vim.notify("No string under the cursor", vim.log.levels.WARN)
		return
	end
	if #token % 4 ~= 0 or not token:match("^[A-Za-z0-9+/]+=?=?$") then
		vim.notify(("'%s' is not a valid base64 string"):format(token), vim.log.levels.WARN)
		return
	end
	local ok, decoded = pcall(vim.base64.decode, token)
	if not ok then
		vim.notify(("'%s' is not a valid base64 string"):format(token), vim.log.levels.WARN)
		return
	end
	if not is_readable(decoded) then
		vim.notify("Decoded content is not a readable string", vim.log.levels.WARN)
		return
	end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_text(0, row - 1, start - 1, row - 1, stop, vim.split(decoded, "\n", { plain = true }))
end

return M
