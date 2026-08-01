local buffers = require("core.ui.buffers.handler")
local tabline = require("core.ui.tabline")
local winbar = require("core.ui.winbar")

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
