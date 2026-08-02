local M = {}

local ns = vim.api.nvim_create_namespace("core_code_base64")
local delimiters = '[%s":%-]'
local saved_windows = {}

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

-- The decoded text is only rendered virtually: the original token stays in
-- the buffer and gets concealed, so the file content never changes.
local function enable_conceal(win)
	if saved_windows[win] then
		return
	end
	saved_windows[win] = {
		conceallevel = vim.wo[win].conceallevel,
		concealcursor = vim.wo[win].concealcursor,
	}
	vim.wo[win].conceallevel = 2
	vim.wo[win].concealcursor = "n"
end

local function restore_conceal(win)
	local saved = saved_windows[win]
	if not saved then
		return
	end
	if vim.api.nvim_win_is_valid(win) then
		vim.wo[win].conceallevel = saved.conceallevel
		vim.wo[win].concealcursor = saved.concealcursor
	end
	saved_windows[win] = nil
end

local function marks_at_cursor()
	local pos = vim.api.nvim_win_get_cursor(0)
	local from = { pos[1] - 1, pos[2] }
	return vim.api.nvim_buf_get_extmarks(0, ns, from, from, { overlap = true })
end

local function show_decoded()
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
	vim.api.nvim_buf_set_extmark(0, ns, row - 1, start - 1, {
		end_col = stop,
		conceal = "",
		virt_text = { { (decoded:gsub("\n", "\\n")), "Base64Decoded" } },
		virt_text_pos = "inline",
	})
	enable_conceal(vim.api.nvim_get_current_win())
end

M.toggle = function()
	local marks = marks_at_cursor()
	if #marks == 0 then
		show_decoded()
		return
	end
	for _, mark in ipairs(marks) do
		vim.api.nvim_buf_del_extmark(0, ns, mark[1])
	end
	if #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) == 0 then
		restore_conceal(vim.api.nvim_get_current_win())
	end
end

M.reset = function()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		end
	end
	for win in pairs(saved_windows) do
		restore_conceal(win)
	end
end

return M
