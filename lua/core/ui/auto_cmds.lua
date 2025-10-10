local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")
local tabline = require_safe("core.ui.tabline")
local winbar = require_safe("core.ui.winbar")

if not (buffers and tabline and winbar) then
	return
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local buf = buffers.create(vim.api.nvim_get_current_buf())
		tabline.create_component(buf)
	end,
})

vim.api.nvim_create_autocmd("BufAdd", {
	callback = function(args)
		local buf = buffers.create(args.buf)
		if buf ~= nil then
			tabline.create_component(buf)
		end
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		tabline.render()
	end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
	callback = function(args)
		vim.schedule(function()
			winbar.update(args)
		end)
	end,
})
