local function relative_path(root, path)
	path = vim.fn.fnamemodify(path, ":h")
	if root == nil or path == "" or path == nil then
		return nil
	end

	path = vim.fn.fnamemodify(path, ":p")
	if vim.fn.isdirectory(path) == 0 or vim.fn.filereadable(path) == 1 then
		return nil
	end

	local cwd_abs = vim.fn.fnamemodify(root, ":p")
	path = path:match(cwd_abs .. "(.*)")

	if path then
		return path:gsub("/$", "")
	end

	return nil
end

return relative_path
