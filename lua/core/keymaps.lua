local require_safe = require("utils.require_safe")

local opts = { noremap = true, silent = true }
local keymap = vim.keymap

local tb = require_safe("core.ui.buffers.handler")
if tb then
	opts.desc = "Load next tabpage in buffer"
	keymap.set("n", "<S-l>", function()
		vim.api.nvim_set_current_buf(tb.next().nr)
	end, opts)

	opts.desc = "Load previous tabpage in buffer"
	keymap.set("n", "<S-h>", function()
		vim.api.nvim_set_current_buf(tb.prev().nr)
	end, opts)

	opts.desc = "Open new tab"
	keymap.set("n", "<S-n>", ":tabnew<CR>", opts)

	opts.desc = "Close current buffer (custom delete)"
	keymap.set("n", "<S-d>", function()
		tb.delete(vim.api.nvim_get_current_buf())
	end, opts)
end
