local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")
local str = require_safe("utils.str")

local boundaries = require_safe("core.ui.components.tabline.boundaries").get()
local name = require_safe("core.ui.components.tabline.name")
local modified = require_safe("core.ui.components.tabline.modified")
local close = require_safe("core.ui.components.tabline.close")
local signs = require_safe("config.signs")

if not (str and buffers and boundaries and name and modified and close and signs) then
	return
end

local M = {}
local sep_left = signs.ui.seperator.left.line
local sep_right = signs.ui.seperator.right.line
local padding = signs.ui.padding

local LOKAL = {
	active = {
		seperator = {
			left = str.highlight("TabLineSepActive", signs.ui.seperator.left.line),
			right = str.highlight("TabLineSepActive", signs.ui.seperator.right.line),
		},
		padding = str.highlight("TabLinePaddingActive", padding),
	},
	inactive = {
		seperator = {
			left = str.highlight("TabLineSepInactive", signs.ui.seperator.left.line),
			right = str.highlight("TabLineSepInactive", signs.ui.seperator.right.line),
		},
		padding = str.highlight("TabLinePaddingInactive", padding),
	},
	components = {},
	length = {
		seperator = {
			left = vim.fn.strdisplaywidth(sep_left),
			right = vim.fn.strdisplaywidth(sep_right),
		},
		padding = vim.fn.strdisplaywidth(padding),
	},
	padding = str.highlight("TabLinePadding", padding),
	tabline = "",
	tabline_bounds = {
		active = nil,
		first = nil,
		last = nil,
	},
	size = 25,
}

local function define_sizes()
	LOKAL.length.cols = vim.o.columns
	LOKAL.length.full = LOKAL.size
	LOKAL.length.content = LOKAL.length.full - LOKAL.length.seperator.left - LOKAL.length.seperator.right
	LOKAL.length.max_length = LOKAL.length.cols - boundaries.length.full.left - boundaries.length.full.right
	LOKAL.components = LOKAL.components or {}
	LOKAL.components = {
		cnt = math.floor(LOKAL.length.max_length / LOKAL.length.full),
		offset = LOKAL.length.max_length % LOKAL.length.full,
	}
	LOKAL.length.name = LOKAL.length.full - modified.length - close.length - 6 * LOKAL.length.padding
end

local function get_active_buffer_index()
	local index = buffers.get_active_buffer_index()
	if index == 0 then
		for _, buffer in ipairs(buffers.items) do
			if buffer.last then
				return buffer.nr
			end
		end
	end
	return index
end

M.create_component = function(buf)
	if buf == nil then
		return
	end
	name.set(buf, LOKAL.length.name)
	LOKAL.components[buf.nr] = {
		name = name.get(buf),
		modified = modified.get(),
		close = close.get(),
	}
end

local function get_bounds(active_component, max_components)
	local remaining = max_components

	local function active()
		return active_component
	end

	local function last()
		local lower_bound = math.min(LOKAL.tabline_bounds.active + 1, #buffers.items)
		local upper_bound = math.min(lower_bound + remaining - 1, #buffers.items)
		local count = upper_bound - lower_bound

		remaining = remaining - count
		return upper_bound == LOKAL.tabline_bounds.active and nil or upper_bound
	end

	local function first()
		local upper_bound = math.max(LOKAL.tabline_bounds.active - 1, 1)
		local lower_bound = math.max(upper_bound - remaining + 1, 1)
		local count = upper_bound - lower_bound

		remaining = remaining - count
		return lower_bound == LOKAL.tabline_bounds.active and nil or lower_bound
	end

	LOKAL.tabline_bounds.active = active()
	LOKAL.tabline_bounds.last = last()
	LOKAL.tabline_bounds.first = first()
end

local function render_components(max_components)
	local components = {}

	local function render_component(buf, active)
		local seperator_left = active and LOKAL.active.seperator.left or LOKAL.inactive.seperator.left
		local seperator_right = active and LOKAL.active.seperator.right or LOKAL.inactive.seperator.right
		local pad = active and LOKAL.active.padding or LOKAL.inactive.padding
		local component = LOKAL.components[buf.nr]
		if component == nil then
			M.create_component(buf)
			component = LOKAL.components[buf.nr]
		end
		return table.concat({
			seperator_left,
			component.name.representation(active),
			component.modified.representation(buf, active),
			component.close.representation(buf, active),
			seperator_right,
		}, pad)
	end

	local function add_padding(count, remaining, right, component)
		if count > 0 and remaining > 0 then
			local pad_length = count * LOKAL.length.padding
			if remaining >= pad_length then
				local pad = count > 1 and str.highlight("TabLinePaddingInactive", string.rep(padding, pad_length))
					or LOKAL.inactive.padding
				remaining = remaining - pad_length
				component = right and component .. pad or pad .. component
			end
		end
		return component, remaining
	end

	local function add_name(buf, remaining, right, visible)
		local component = LOKAL.components[buf.nr]

		local function add_icon()
			if remaining < buf.file.length.icon then
				return add_padding(remaining, remaining, right, visible)
			end
			local icon = str.highlight("TabLineIconInactive", buf.file.icon)
			visible = right and visible .. icon or icon .. visible
			remaining = remaining - buf.file.length.icon
			return visible, remaining
		end

		local function add_name_new()
			local name_len = math.min(remaining, component.name.length.max)
			if name_len > 0 then
				local visible_name = right and string.sub(buf.file.name, 1, name_len)
					or string.sub(buf.file.name, -name_len)
				local hl_name = str.highlight("TabLineNameInactive", visible_name)
				visible = right and visible .. hl_name or hl_name .. visible
				remaining = remaining - name_len
			end
			return visible, remaining
		end

		if remaining >= LOKAL.length.name then
			local full_name = component.name.representation(false)
			visible = right and visible .. full_name or full_name .. visible
			remaining = remaining - LOKAL.length.name
		else
			local pad = right and component.name.length.padding.left or component.name.length.padding.right
			visible, remaining = add_padding(math.min(pad, remaining), remaining, right, visible)
			if right then
				visible, remaining = add_icon()
				visible, remaining = add_padding(1, remaining, right, visible)
				visible, remaining = add_name_new()
			else
				visible, remaining = add_name_new()
				visible, remaining = add_padding(1, remaining, right, visible)
				visible, remaining = add_icon()
			end
			pad = right and component.name.length.padding.right or component.name.length.padding.left
			visible, remaining = add_padding(math.min(pad, remaining), remaining, right, visible)
		end
		return add_padding(1, remaining, right, visible)
	end

	local function add_modified(buf, remaining, right, visible)
		if remaining >= LOKAL.components[buf.nr].modified.length then
			local mod = LOKAL.components[buf.nr].modified.representation(buf, false)
			visible = right and visible .. mod or mod .. visible
			remaining = remaining - LOKAL.components[buf.nr].modified.length
		else
			visible, remaining = add_padding(remaining, remaining, right, visible)
		end
		return add_padding(1, remaining, right, visible)
	end

	local function add_close(buf, remaining, right, visible)
		local new, free = LOKAL.components[buf.nr].close.shorten(buf, remaining, right, visible)
		if free == remaining and new == visible then
			return add_padding(remaining, remaining, right, visible)
		end
		return add_padding(1, free, right, new)
	end

	local function shorten_right_component(buf)
		local offset = LOKAL.components.offset
		local left_sep_len = LOKAL.length.seperator.left
		local right_sep_len = LOKAL.length.seperator.right
		local component = LOKAL.components[buf.nr]

		if right_sep_len >= offset == right_sep_len + LOKAL.length.seperator.right then
			table.insert(components, str.highlight("TabLinePadding", string.rep(padding, LOKAL.components.offset)))
			return
		end

		local remaining = offset - left_sep_len - right_sep_len
		local visible = LOKAL.inactive.seperator.left
		if component == nil then
			visible, _ = add_padding(remaining, remaining, true, visible)
			table.insert(components, visible .. visible .. LOKAL.inactive.seperator.right)
			return
		end

		visible, remaining = add_padding(1, remaining, true, visible)

		visible, remaining = add_name(buf, remaining, true, visible)
		visible, remaining = add_modified(buf, remaining, true, visible)
		visible, remaining = add_close(buf, remaining, true, visible)

		visible, remaining = add_padding(remaining, remaining, true, visible)
		visible = visible .. LOKAL.inactive.seperator.right

		table.insert(components, visible)
	end

	local function shorten_left_component(buf)
		local offset = LOKAL.components.offset
		local left_sep_len = LOKAL.length.seperator.left
		local right_sep_len = LOKAL.length.seperator.right
		local component = LOKAL.components[buf.nr]

		if offset <= left_sep_len or offset == left_sep_len + right_sep_len then
			table.insert(components, str.highlight("TabLinePadding", string.rep(padding, offset)))
			return
		end

		local remaining = offset - left_sep_len - right_sep_len
		local visible = LOKAL.inactive.seperator.right
		if component == nil then
			visible, _ = add_padding(remaining, remaining, false, visible)
			table.insert(components, visible .. visible .. LOKAL.inactive.seperator.right)
			return
		end

		visible, remaining = add_padding(1, remaining, false, visible)

		visible, remaining = add_close(buf, remaining, false, visible)
		visible, remaining = add_modified(buf, remaining, false, visible)
		visible, remaining = add_name(buf, remaining, false, visible)

		visible, remaining = add_padding(remaining, remaining, false, visible)

		visible = LOKAL.inactive.seperator.left .. visible
		table.insert(components, 1, visible)
	end

	local function render_active_component()
		if LOKAL.tabline_bounds.active ~= nil then
			components[1] = render_component(buffers.items[LOKAL.tabline_bounds.active], true)
		end
	end

	local function render_last_components()
		if LOKAL.tabline_bounds.active ~= nil and LOKAL.tabline_bounds.last ~= nil then
			for i = LOKAL.tabline_bounds.active + 1, LOKAL.tabline_bounds.last do
				if #components == max_components then
					LOKAL.tabline_bounds.last = i
					shorten_right_component(buffers.items[i])
					return
				end
				components[#components + 1] = render_component(buffers.items[i], false)
			end
		end
	end

	local function render_first_components()
		if #components > max_components then
			LOKAL.tabline_bounds.first = LOKAL.tabline_bounds.active
			return
		end
		if LOKAL.tabline_bounds.active ~= nil and LOKAL.tabline_bounds.first ~= nil then
			for i = LOKAL.tabline_bounds.active - 1, LOKAL.tabline_bounds.first, -1 do
				if #components == max_components then
					LOKAL.tabline_bounds.first = i
					shorten_left_component(buffers.items[i])
					return
				end
				table.insert(components, 1, render_component(buffers.items[i], false))
			end
		end
	end

	render_active_component()
	render_last_components()
	render_first_components()

	if #components <= max_components then
		local pad = str.highlight(
			"TabLinePadding",
			string.rep(padding, (max_components - #components) * LOKAL.length.full + LOKAL.components.offset)
		)
		components[#components + 1] = pad
	end

	if LOKAL.tabline_bounds.first ~= nil then
		local first = LOKAL.tabline_bounds.active == LOKAL.tabline_bounds.first and LOKAL.tabline_bounds.first
			or LOKAL.tabline_bounds.first
		table.insert(components, 1, boundaries.left(first))
	end
	if LOKAL.tabline_bounds.last ~= nil then
		table.insert(components, boundaries.right(LOKAL.tabline_bounds.last))
	end

	return components
end

M.render = function()
	if vim.o.columns ~= LOKAL.length.cols then
		define_sizes()
	end
	local active = get_active_buffer_index()
	if buffers.items[active] == nil then
		return LOKAL.tabline
	end

	get_bounds(active, LOKAL.components.cnt)
	local components = render_components(LOKAL.components.cnt)

	LOKAL.tabline = table.concat(components)
	return LOKAL.tabline
end

M.setup = function(size)
	LOKAL.size = size or LOKAL.size
	-- Default should be 25.
	-- Test close left: 23, right: 71
	define_sizes()

	vim.o.showtabline = 2
	vim.o.tabline = "%!v:lua.require('core.ui.tabline').render()"
end

return M
