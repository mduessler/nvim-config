local M = {}

M.collected = {}

-- Headless only: collect deprecations and warning notifications so the
-- bootstrap (InitNVIM) can fail on them instead of scrolling them away.
M.setup = function()
	if #vim.api.nvim_list_uis() ~= 0 then
		return
	end

	vim.deprecate = function(name, alternative, version)
		local msg = ("%s is deprecated"):format(name)
		if alternative then
			msg = msg .. (", use %s instead"):format(alternative)
		end
		if version then
			msg = msg .. (" (removal in nvim %s)"):format(version)
		end
		table.insert(M.collected, msg)
	end

	local notify = vim.notify
	vim.notify = function(msg, level, opts)
		if type(level) == "number" and level >= vim.log.levels.WARN then
			table.insert(M.collected, tostring(msg))
		end
		return notify(msg, level, opts)
	end
end

return M
