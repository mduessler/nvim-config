local require_safe = require("utils.require_safe")

local colors = require_safe("core.colors")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (colors and signs and str) then
	return
end

local padding = signs.ui.padding

local M = {}

local LOCAL = {
	padding = {
		active = str.highlight("TablinePaddingActive", padding),
		inactive = str.highlight("TablinePaddingInactive", padding),
	},
	length = {
		max = 25,
		more = vim.fn.strdisplaywidth("..."),
		padding = vim.fn.strdisplaywidth(padding),
	},
	buffers = {},
}

local function hl_name(buf, name)
	local function calculate_padding()
		local pad_size = math.max(0, LOCAL.buffers[buf.file.name].length - #name)
		local left_pad_size = math.floor(pad_size / 2)
		LOCAL.buffers[buf.file.name][buf.nr].length.name = vim.fn.strdisplaywidth(name)
		LOCAL.buffers[buf.file.name][buf.nr].length.padding = {
			left = left_pad_size,
			right = pad_size % 2 == 0 and left_pad_size or left_pad_size + 1,
		}
		return LOCAL.buffers[buf.file.name][buf.nr].length.padding.left,
			LOCAL.buffers[buf.file.name][buf.nr].length.padding.right
	end
	calculate_padding()
	if #name > LOCAL.buffers[buf.file.name].length then
		name = string.sub(name, 1, LOCAL.buffers[buf.file.name].length - LOCAL.length.more) .. "..."
	end

	local pad_left = string.rep(padding, LOCAL.buffers[buf.file.name][buf.nr].length.padding.left)
	local pad_right = string.rep(padding, LOCAL.buffers[buf.file.name][buf.nr].length.padding.right)

	vim.api.nvim_set_hl(
		0,
		"TabLineIconActive" .. tostring(buf.nr),
		{ bg = colors.tabline.bg.active, fg = buf.file.color }
	)
	LOCAL.buffers[buf.file.name][buf.nr].active = {
		icon = str.highlight("TabLineIconActive" .. tostring(buf.nr), buf.file.icon),
		name = str.highlight("TabLineNameActive", name),
		padding = {
			left = str.highlight("TablinePaddingActive", pad_left),
			right = str.highlight("TablinePaddingActive", pad_right),
		},
	}
	LOCAL.buffers[buf.file.name][buf.nr].inactive = {
		icon = str.highlight("TabLineIconInactive", buf.file.icon),
		name = str.highlight("TabLineNameInactive", name),
		padding = {
			left = str.highlight("TablinePaddingInactive", pad_left),
			right = str.highlight("TablinePaddingInactive", pad_right),
		},
	}
end

local function init_buf(buf, name_length)
	LOCAL.buffers[buf.file.name] = LOCAL.buffers[buf.file.name] or {}
	LOCAL.buffers[buf.file.name][buf.nr] = LOCAL.buffers[buf.file.name][buf.nr] or {}
	LOCAL.buffers[buf.file.name][buf.nr].buf = buf
	LOCAL.buffers[buf.file.name].length = name_length - buf.file.length.icon - LOCAL.length.padding
	LOCAL.buffers[buf.file.name][buf.nr].length = {
		max = LOCAL.buffers[buf.file.name].length,
		padding = {},
	}
end

local function generate_name(buf)
	local function split_path(path)
		local components = {}
		for part in path:gmatch("[^/]+") do
			table.insert(components, part)
		end
		return components
	end

	local target_path = split_path(buf.file.path)
	local buffers = LOCAL.buffers[buf.file.name]

	if not buffers then
		return buf.file.name
	end

	local longest_suffix = {}

	for nr, state in pairs(buffers) do
		if nr ~= buf.nr and type(state) == "table" and state.buf then
			local other_path = split_path(state.buf.file.path)
			local tmp = {}
			local i = 0

			while target_path[#target_path - i] and target_path[#target_path - i] == other_path[#other_path - i] do
				table.insert(tmp, 1, target_path[#target_path - i])
				i = i + 1
			end

			if #target_path - i > 0 then
				table.insert(tmp, 1, target_path[#target_path - i])
			end

			if #tmp > #longest_suffix then
				longest_suffix = tmp
			end
		end
	end

	table.insert(longest_suffix, buf.file.name)
	return table.concat(longest_suffix, "/")
end

local function generate_name_for_buffers(filename)
	for _, buffer in pairs(LOCAL.buffers[filename]) do
		if type(buffer) == "table" then
			local name = generate_name(buffer.buf)
			hl_name(buffer.buf, name)
		end
	end
end

M.set = function(buf, name_length)
	init_buf(buf, name_length)
	generate_name_for_buffers(buf.file.name)
end

M.get = function(buf)
	local focus_buffer_name = function(name)
		local focus_fn_name = "TablineFocusBuffer" .. buf.nr
		_G[focus_fn_name] = function()
			vim.api.nvim_set_current_buf(buf.nr)
			vim.cmd("redrawtabline")
		end
		return string.format("%%@v:lua.%s@%s%%X", focus_fn_name, name)
	end

	local function representation(active)
		local pad = active and LOCAL.padding.active or LOCAL.padding.inactive
		local state = active and LOCAL.buffers[buf.file.name][buf.nr].active
			or LOCAL.buffers[buf.file.name][buf.nr].inactive
		return state.padding.left .. focus_buffer_name(state.icon .. pad .. state.name) .. state.padding.right
	end

	return { length = LOCAL.buffers[buf.file.name][buf.nr].length, representation = representation }
end

vim.api.nvim_create_autocmd("BufWipeout", {
	callback = function(args)
		local buf = args.buf
		local path = vim.api.nvim_buf_get_name(buf)
		local filename = vim.fn.fnamemodify(path, ":t")
		if LOCAL.buffers[filename] then
			LOCAL.buffers[filename][buf] = nil
			generate_name_for_buffers(filename)
		end
	end,
})

return M
