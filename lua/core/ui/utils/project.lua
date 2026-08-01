local git = require("core.utils.git.handler")

local M = { root = "", is_git_repo = false, git = {} }

local function get_root(path)
	if path == "" or path == nil then
		path = vim.fn.getcwd()
	end

	path = vim.fn.fnamemodify(path, ":p")

	if vim.fn.isdirectory(path) == 0 then
		if vim.fn.filereadable(path) == 1 then
			path = vim.fn.fnamemodify(path, ":h")
		end
	end

	local cmd = "git -C " .. vim.fn.shellescape(path) .. " rev-parse --show-toplevel"
	local output = vim.fn.systemlist(cmd)

	if vim.v.shell_error ~= 0 then
		M.root = path
		M.is_git_repo = false
	else
		M.root = output[1]
		M.is_git_repo = true
	end
end

M.setup = function(path)
	if M.root ~= "" then
		return
	end

	get_root(path)
	if M.is_git_repo then
		M.git = git
		M.git.run(M.root)
	end
end

return M
