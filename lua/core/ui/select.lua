local require_safe = require("utils.require_safe")

local keymap = require_safe("utils.key")
local mode = require_safe("core.ui.utils.mode")
local window = require_safe("core.ui.windows.utils")

if not (mode and keymap and window) then
	return
end

local M = {
	text = {
		search_icon = " ",
		start_icon = " ",
	},
}

local ns = vim.api.nvim_create_namespace("vim_ui_select")

local function float_config(height, prompt)
	local ui = vim.api.nvim_list_uis()[1]
	height = math.min(math.floor(ui.height / 2), height)

	return {
		relative = "editor",
		row = math.floor(ui.height / 4),
		col = math.floor(ui.width / 4),
		width = math.floor(ui.width / 2),
		height = height,
		style = "minimal",
		border = "rounded",
		title = prompt,
		title_pos = "center",
	}
end

local function render(bufnr, winid)
	vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
	vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {
		end_col = #M.text.search_icon,
		hl_group = "VimUiInputStartIcon",
	})
	local line = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1]
	vim.api.nvim_buf_set_extmark(bufnr, ns, 1, 0, {
		end_col = #line,
		hl_group = "FloatBorder",
	})
	local row, _ = window.position(winid)
	if row > 2 then
		vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = winid })
	else
		vim.api.nvim_set_option_value("cursorline", false, { scope = "local", win = winid })
	end
end

local function create_mapping(items, format_item)
	local map = {}
	for _, item in ipairs(items) do
		local value = format_item and format_item(item) or item
		map[item] = { [1] = value:lower(), [2] = value }
	end
	return map
end

local function format_lines(map, input, width)
	local lines = { M.text.search_icon .. input, string.rep("─", width) }
	input = input:lower() or ""
	for _, values in pairs(map) do
		if string.find(values[1], input) then
			table.insert(lines, M.text.start_icon .. values[2])
		end
	end
	return lines
end

local function get_line(bufnr, winid)
	local row, _ = window.position(winid)
	local icon = M.text.start_icon
	if row < 3 then
		row = 1
		icon = M.text.search_icon
	end

	local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
	line = line:sub(#icon)
	line = line:gsub("%s+", ""):lower()
	return line
end

local function first_row_handler(winid, col)
	vim.defer_fn(function()
		vim.cmd("startinsert")
		local min_col = #M.text.search_icon
		if col < min_col then
			vim.api.nvim_win_set_cursor(winid, { 1, min_col })
		end
	end, 0)
end

local function handle_selection(winid, on_choice, choice)
	window.close(winid)
	if type(on_choice) == "function" then
		on_choice(choice)
	end
end

M.select = function(items, opts, on_choice)
	opts = opts or { format_item = nil }
	local map = create_mapping(items, opts.format_item)
	local original_mode = vim.api.nvim_get_mode().mode
	local ui = vim.api.nvim_list_uis()[1]
	local width = math.floor(ui.width / 2)

	local lines = format_lines(map, "", width)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win(bufnr, true, float_config(#lines, opts.prompt or ""))

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "nofile"
	vim.b[bufnr].cmp_enabled = false -- vim.b is correct!!
	render(bufnr, winid)

	local key_options = { buffer = bufnr, nowait = true, silent = true }

	keymap.set({ "i", "n" }, "<CR>", function()
		local line = get_line(bufnr, winid)
		for key, value in pairs(map) do
			if value[1] == line then
				handle_selection(winid, on_choice, key)
			end
		end
	end, key_options)

	keymap.set({ "i", "n" }, "<Esc>", function()
		handle_selection(winid, on_choice)
	end, key_options)

	keymap.set("n", "q", function()
		handle_selection(winid, on_choice)
	end, key_options)

	vim.api.nvim_create_autocmd("WinEnter", {
		buffer = bufnr,
		once = true,
		callback = function()
			local row, col = window.position(winid)
			if row == 1 then
				first_row_handler(winid, col)
			end
		end,
	})

	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = bufnr,
		callback = function()
			window.close(winid)
			mode.restore(original_mode)
		end,
		once = true,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = bufnr,
		callback = function()
			local row, col = window.position(winid)
			local min_col = #M.text.search_icon

			if row == 1 then
				local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
				lines = format_lines(map, line:sub(min_col + 1), width)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
				first_row_handler(winid, col)
			else
				if vim.api.nvim_get_mode().mode == "i" then
					vim.cmd("stopinsert")
				end
			end
			render(bufnr, winid)
		end,
	})
end

return M
