local require_safe = require("utils.require_safe")
local close_process = require_safe("core.utils.async.close_process")
local close_timer = require_safe("core.utils.async.close_timer")
local commit = require_safe("core.update.git.commit")
local ref_type = require_safe("core.update.git.reference.type")

if not (close_process and close_timer and commit and ref_type) then
	return
end

local M = {
	running = {
		commit = false,
		reference = {
			name = false,
			type = false,
		},
		timer = false,
	},
	handle = {
		commit = false,
		reference = {
			name = nil,
			type = nil,
		},
	},
	commit = nil,
	reference = {
		name = nil,
		type = nil,
	},
}

local function closehandles()
	for _, handle in ipairs({
		M.handle.commit,
		M.handle.reference.type,
	}) do
		close_process(handle)
	end
	close_timer(M.handle.timer)
end

M.run = function()
	if M.running.timer then
		return
	end

	closehandles()

	M.handle.timer = vim.loop.new_timer()
	M.handle.timer:start(
		0,
		500,
		vim.schedule_wrap(function()
			commit(M)
			if M.commit ~= nil then
				ref_type(M)
			end
		end)
	)
end

return M
