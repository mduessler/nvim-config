local require_safe = require("utils.require_safe")
local close_process = require_safe("core.utils.async.close_process")
local close_timer = require_safe("core.utils.async.close_timer")
local commit = require_safe("core.utils.git.commit.long")
local date = require_safe("core.utils.git.commit.date")
local logger = require_safe("utils.logger")
local ref_name = require_safe("core.utils.git.reference.type")
local ref_type = require_safe("core.util.git.reference.name")

if not (close_process and close_timer and commit and date and logger and ref_name and ref_type) then
	return
end

local M = {
	_running = {
		commit = {
			long = false,
			date = false,
		},
		reference = {
			name = false,
			type = false,
		},
		timer = false,
	},
	_handle = {
		commit = {
			long = nil,
			date = nil,
		},
		reference = {
			name = nil,
			type = nil,
		},
	},
	commit = {
		long = nil,
		date = nil,
	},
	reference = {
		name = nil,
		type = nil,
	},
}

local function closehandles()
	for _, handle in ipairs({
		M._handle.commit.long,
		M._handle.reference.name,
		M._handle.reference.type,
	}) do
		close_process(handle)
	end
	close_timer(M._handle.timer)
end

M.run = function()
	if M._running.timer then
		return
	end

	closehandles()

	M._handle.timer = vim.loop.new_timer()
	M._handle.timer:start(
		0,
		500,
		vim.schedule_wrap(function()
			if M.commit.long == nil then
				commit(M)
			end
			if M.commit ~= nil and M.reference.type == nil then
				ref_type(M)
			end
			if M.reference.type ~= nil and M.reference.name == nil then
				ref_name(M)
			end
			if M.reference.type ~= nil and M.reference.date == nil then
				date(M)
			end
			if M.reference.name ~= nil and M.commit.date ~= nil then
				if M.reference.type == "branch" then
					if M.reference.name == "main" then
						logger.info("Download main")
					end
					logger.INFO(
						"TYPE branch detected. Checking if it is main. If it is main, compare dates, if remote newer, than give update notification."
					)
				elseif M.reference.type == "ref" then
					logger.INFO(
						"TYPE ref detected. CHECK if installed nvim version is equal to ref version. Else check if version exists. Then notify user about that."
					)
				else
					logger.INFO("On stale commit. notify that update is only possible on a stable ref or main.")
				end
			end
		end)
	)
end

return M
