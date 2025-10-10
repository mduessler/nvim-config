local function require_safe(module)
	local status, result = pcall(require, module)
	if not status then
		vim.schedule(function()
			vim.notify("require_safe: failed to load " .. module .. " (" .. result .. ")", vim.log.levels.ERROR)
		end)
		return nil
	end
	return result
end

return require_safe
