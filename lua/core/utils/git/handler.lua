local require_safe = require("utils.require_safe")

local changes = require_safe("core.utils.git.changes")
local close_process = require_safe("core.utils.async.close_process")
local close_timer = require_safe("core.utils.async.close_timer")
local commit_long = require_safe("core.utils.git.commit.long")
local commit_short = require_safe("core.utils.git.commit.short")
local commits_to_pull = require_safe("core.utils.git.commits_to_pull")
local commits_to_push = require_safe("core.utils.git.commits_to_push")
local fetch = require_safe("core.utils.git.fetch")
local logger = require_safe("utils.logger")
local status = require_safe("core.utils.git.status")
local reference = require_safe("core.utils.git.reference")

if
	not (
		changes
		and close_process
		and close_timer
		and commit_long
		and commit_short
		and commits_to_pull
		and commits_to_push
		and fetch
		and logger
		and status
		and reference
	)
then
	return
end

local M = {
	cwd = nil,
	_running = {
		commit = {
			long = false,
			short = false,
		},
		timer = false,
		reference = false,
		status = false,
		changes = false,
		commits_to_push = false,
		commots_to_pull = false,
		fetch = false,
		reference_date = false,
	},
	_handle = {
		commit = { long = nil, short = nil },
		timer = nil,
		reference = nil,
		status = nil,
		changes = nil,
		commits_to_pull = nil,
		commits_to_push = nil,
		fetch = nil,
		reference_date = nil,
	},
	commit = {
		long = "",
		short = "",
	},
	fetch = false,
	reference_date = nil,
	reference = "",
	modified = false,
	changes = { NOFILE = { added = 0, deleted = 0 } },
	commits_to_pull = false,
	commits_to_push = false,
}

local function close_handles()
	for _, handle in ipairs({
		M._handle.commit.long,
		M._handle.commit.short,
		M._handle.fetch,
		M._handle.reference,
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
			commit_long(M)
			commit_short(M)
			reference(M)
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

--- Function to run the fetch option async.
---@param ref string Reference to fetch from remote
M.fetch = function(ref)
	if M._running.fetch then
		logger.INFO("Fetch process already running. Only one fetch is allowed at a time.")
		return
	end
	local timer = vim.loop.new_timer()
	timer:start(
		1000,
		0,
		vim.schedule_wrap(function()
			logger.DEBUG(string.format("Started fetch process for reference '%s'", ref))
			fetch(M, ref)
			timer:close()
		end)
	)
end

return M
