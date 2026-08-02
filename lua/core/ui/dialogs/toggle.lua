--- Floating window to toggle lsp servers, linters and formatters at
--- runtime. The toggle state and side effects live in core.toggle.

local float = require("core.ui.dialogs.float")
local frame = require("core.ui.dialogs.frame")
local keymap = require("utils.key")
local toggle = require("core.toggle")
local window = require("core.ui.windows.utils")

local M = {}

local ns = vim.api.nvim_create_namespace("core_ui_toggle")

local icons = require("config.signs").ui.dialogs

local headers = {
	lsp = "LSP",
	linter = "Linter",
	formatter = "Formatter",
}

local function build(tools, width)
	local lines = {}
	local meta = {}

	local function add(line, entry)
		table.insert(lines, line)
		meta[#lines] = entry or { frame = true }
	end

	for _, kind in ipairs(toggle.kinds) do
		if #tools[kind] > 0 then
			if #lines > 0 then
				add("", { frame = true })
			end
			add(frame.top(width))
			add(frame.framed(headers[kind] .. ":", width), { header = true })
			add(frame.framed(string.rep("─", width - 4), width))
			for _, name in ipairs(tools[kind]) do
				local icon = toggle.is_enabled(kind, name) and icons.on or icons.off
				add(frame.framed(icons.entry .. name, width, icon), { kind = kind, name = name })
			end
			add(frame.bottom(width))
		end
	end

	if #lines == 0 then
		add("No tools available for this filetype.", { header = true })
	end

	return lines, meta
end

local function render(bufnr, lines, meta)
	vim.bo[bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].modifiable = false

	local edge = #frame.border.vertical + 1 -- byte length of the "│ " prefix

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	for lnum, entry in pairs(meta) do
		local line = lines[lnum]
		if entry.frame then
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
				end_col = #line,
				hl_group = "FloatBorder",
			})
		elseif not vim.startswith(line, frame.border.vertical) then
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
				end_col = #line,
				hl_group = "Title",
			})
		else
			-- Frame edges of header and entry lines.
			for _, range in ipairs({ { 0, edge }, { #line - edge, #line } }) do
				vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, range[1], {
					end_col = range[2],
					hl_group = "FloatBorder",
				})
			end
			if entry.header then
				vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, edge, {
					end_col = #line - edge,
					hl_group = "Title",
				})
			else
				local enabled = toggle.is_enabled(entry.kind, entry.name)
				vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, edge + #icons.entry, {
					end_col = #line - edge,
					hl_group = enabled and "DiagnosticOk" or "DiagnosticError",
				})
			end
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

	local bufnr, winid = float.open(float.editor_config(width, #lines, title(scope)), { hide_cursor = true })
	vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = winid })

	render(bufnr, lines, meta)

	local key_options = float.key_options(bufnr)

	keymap.set("n", "<CR>", function()
		local row = vim.api.nvim_win_get_cursor(winid)[1]
		local entry = meta[row]
		if not entry or entry.header or entry.frame then
			return
		end
		toggle.toggle(entry.kind, entry.name)
		lines, meta = build(toggle.tools(scope), width)
		render(bufnr, lines, meta)
	end, key_options)

	keymap.set("n", "a", function()
		scope = scope == nil and ft or nil
		lines, meta = build(toggle.tools(scope), width)
		vim.api.nvim_win_set_config(winid, float.editor_config(width, #lines, title(scope)))
		render(bufnr, lines, meta)
	end, key_options)

	for _, key in ipairs({ "q", "<Esc>" }) do
		keymap.set("n", key, function()
			window.close(winid)
		end, key_options)
	end
end

M.setup = function()
	vim.api.nvim_create_user_command("ToggleTools", M.open, { desc = "Toggle lsp servers, linters and formatters" })
end

return M
