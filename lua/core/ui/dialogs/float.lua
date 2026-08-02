--- Shared float shell for the dialog components: window config, scratch
--- buffer setup and the common close behaviour.

local window = require("core.ui.windows.utils")

local M = {}

--- Centered editor overlay used by the list dialogs.
M.editor_config = function(width, height, title)
	local ui = vim.api.nvim_list_uis()[1] or { width = 80, height = 24 }
	height = math.min(math.floor(ui.height / 2), height)

	return {
		relative = "editor",
		row = math.floor(ui.height / 4),
		col = math.floor((ui.width - width) / 2),
		width = width,
		height = math.max(height, 1),
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
	}
end

--- Opens a scratch float with the shared dialog buffer setup.
---
--- opts.winleave_close (default true) closes the window when it is left;
--- opts.on_leave runs afterwards. Dialogs that manage their own lifetime
--- (like input via BufWipeout) disable winleave_close explicitly.
--- opts.hide_cursor blends the cursor away while the dialog is open, so
--- only the cursorline marks the position.
M.open = function(config, opts)
	opts = opts or {}

	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win(bufnr, true, config)

	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "nofile"
	vim.b[bufnr].cmp_enabled = false

	local guicursor = vim.o.guicursor
	if opts.hide_cursor then
		vim.api.nvim_set_hl(0, "DialogHiddenCursor", { blend = 100, nocombine = true })
		vim.o.guicursor = "a:DialogHiddenCursor"
	end

	if opts.winleave_close ~= false then
		vim.api.nvim_create_autocmd("WinLeave", {
			buffer = bufnr,
			once = true,
			callback = function()
				if opts.hide_cursor then
					vim.o.guicursor = guicursor
				end
				window.close(winid)
				if opts.on_leave then
					opts.on_leave()
				end
			end,
		})
	end

	return bufnr, winid
end

--- Mapping options shared by the dialog keymaps.
M.key_options = function(bufnr)
	return { buffer = bufnr, nowait = true, silent = true }
end

return M
