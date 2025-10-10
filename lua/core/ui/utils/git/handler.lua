local require_safe = require("utils.require_safe")

local close_process = require_safe("core.ui.utils.async.close_process")
local close_timer = require_safe("core.ui.utils.async.close_timer")
local branch = require_safe("core.ui.utils.git.branch")
local status = require_safe("core.ui.utils.git.status")
local changes = require_safe("core.ui.utils.git.changes")
local commits_to_pull = require_safe("core.ui.utils.git.commits_to_pull")
local commits_to_push = require_safe("core.ui.utils.git.commits_to_push")

if not (close_process and close_timer and branch and status and changes and commits_to_pull and commits_to_push) then
	return
end

local M = {
	cwd = nil,
	_running = {
		timer = false,
		branch = false,
		status = false,
		changes = false,
		commits_to_push = false,
		commots_to_pull = false,
	},
	_handle = {
		timer = nil,
		branch = nil,
		status = nil,
		changes = nil,
		commits_to_pull = nil,
		commits_to_push = nil,
	},
	branch = "",
	modified = false,
	changes = { NOFILE = { added = 0, deleted = 0 } },
	commits_to_pull = false,
	commits_to_push = false,
}

local function close_handles()
	for _, handle in ipairs({
		M._handle.branch,
		M._handle.status,
		M._handle.changes,
		M._handle.commits_to_pull,
		M._handle.commits_to_push,
	}) do
		close_process(handle)
	end
	close_timer(M._handle.timer)
end

M.run = function(cwd)
	M.cwd = cwd
	if M._running.timer then
		return
	end

	close_handles()

	M._handle.timer = vim.loop.new_timer()
	M._handle.timer:start(
		0,
		1000,
		vim.schedule_wrap(function()
			branch(M)
			status(M)
			changes(M)
			commits_to_pull(M)
			commits_to_push(M)
		end)
	)

	vim.api.nvim_create_augroup("GitUtilsCleanup", { clear = true })

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = "GitUtilsCleanup",
		callback = function()
			close_handles()
		end,
	})
end

return M
