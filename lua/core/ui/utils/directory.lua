local M = {}

M.is_subpath = function(path, base_dir)
	base_dir = vim.fn.fnamemodify(base_dir, ":p"):gsub("/+$", "") .. "/"
	path = vim.fn.fnamemodify(path, ":p")

	return path:sub(1, #base_dir) == base_dir
end

M.get_subdir = function(path, base_dir)
	base_dir = vim.fn.fnamemodify(base_dir, ":p"):gsub("/+$", "") .. "/"
	path = vim.fn.fnamemodify(path, ":p")

	if path:sub(1, #base_dir) ~= base_dir then
		return nil
	end

	local relative_path = path:sub(#base_dir + 1)
	local dir = relative_path:match("(.*/)")
	return dir or ""
end

return M
