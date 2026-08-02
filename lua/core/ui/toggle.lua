--- Floating window to toggle lsp servers, linters and formatters at
--- runtime. The toggle state and side effects live in core.toggle.

local keymap = require("utils.key")
local toggle = require("core.toggle")
local window = require("core.ui.windows.utils")

local M = {}

local ns = vim.api.nvim_create_namespace("core_ui_toggle")

local icons = {
	on = " ",
	off = " ",
	entry = " ",
}

local headers = {
	lsp = "LSP",
	linter = "Linter",
	formatter = "Formatter",
}

local function float_config(height, title)
	local ui = vim.api.nvim_list_uis()[1] or { width = 80, height = 24 }
	local width = math.floor(ui.width / 3)
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

local function build(tools, width)
	local lines = {}
	local meta = {}

	for _, kind in ipairs(toggle.kinds) do
		if #tools[kind] > 0 then
			table.insert(lines, headers[kind] .. ":")
			meta[#lines] = { header = true }
			table.insert(lines, string.rep("─", width))
			meta[#lines] = { separator = true }
			for _, name in ipairs(tools[kind]) do
				local icon = toggle.is_enabled(kind, name) and icons.on or icons.off
				table.insert(lines, icons.entry .. icon .. name)
				meta[#lines] = { kind = kind, name = name }
			end
		end
	end

	if #lines == 0 then
		lines = { "No tools available for this filetype." }
		meta[1] = { header = true }
	end

	return lines, meta
end

local function render(bufnr, lines, meta)
	vim.bo[bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].modifiable = false

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	for lnum, entry in pairs(meta) do
		if entry.header then
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
				end_col = #lines[lnum],
				hl_group = "Title",
			})
		elseif entry.separator then
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
				end_col = #lines[lnum],
				hl_group = "FloatBorder",
			})
		else
			local enabled = toggle.is_enabled(entry.kind, entry.name)
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, #icons.entry, {
				end_col = #lines[lnum],
				hl_group = enabled and "DiagnosticOk" or "DiagnosticError",
			})
		end
	end
end

local function title(ft)
	if ft then
		return " Tools (" .. ft .. ") - <CR> toggle, a all, q close "
	end
	return " Tools (all) - <CR> toggle, a filetype, q close "
end

M.open = function()
	local ft = vim.bo.filetype
	ft = ft ~= "" and ft or nil

	local ui_info = vim.api.nvim_list_uis()[1] or { width = 80, height = 24 }
	local width = math.floor(ui_info.width / 3)

	local scope = ft
	local lines, meta = build(toggle.tools(scope), width)

	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win(bufnr, true, float_config(#lines, title(scope)))

	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].filetype = "nofile"
	vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = winid })

	render(bufnr, lines, meta)

	local key_options = { buffer = bufnr, nowait = true, silent = true }

	keymap.set("n", "<CR>", function()
		local row = vim.api.nvim_win_get_cursor(winid)[1]
		local entry = meta[row]
		if not entry or entry.header or entry.separator then
			return
		end
		toggle.toggle(entry.kind, entry.name)
		lines, meta = build(toggle.tools(scope), width)
		render(bufnr, lines, meta)
	end, key_options)

	keymap.set("n", "a", function()
		scope = scope == nil and ft or nil
		lines, meta = build(toggle.tools(scope), width)
		vim.api.nvim_win_set_config(winid, float_config(#lines, title(scope)))
		render(bufnr, lines, meta)
	end, key_options)

	for _, key in ipairs({ "q", "<Esc>" }) do
		keymap.set("n", key, function()
			window.close(winid)
		end, key_options)
	end

	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = bufnr,
		once = true,
		callback = function()
			window.close(winid)
		end,
	})
end

M.setup = function()
	vim.api.nvim_create_user_command("ToggleTools", M.open, { desc = "Toggle lsp servers, linters and formatters" })
end

return M
