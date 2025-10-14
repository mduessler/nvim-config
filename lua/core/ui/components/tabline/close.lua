local require_safe = require("utils.require_safe")

local str = require_safe("utils.str")
local signs = require_safe("config.signs")

if not (str and signs) then
	return
end

local M = {}

local padding = signs.ui.padding
local separator = signs.ui.separator.default
local sign = signs.quit.icon

local LOCAL = {
	active = {
		padding = str.highlight("TabLinePaddingActive", padding),
		separator = str.highlight("TabLineCloseSepActive", separator),
		sign = str.highlight("TabLineCloseActive", sign),
	},
	inactive = {
		padding = str.highlight("TabLinePaddingInactive", padding),
		separator = str.highlight("TabLineCloseSepInactive", separator),
		sign = str.highlight("TabLineCloseInactive", sign),
	},
	length = {
		padding = vim.fn.strdisplaywidth(padding),
		separator = vim.fn.strdisplaywidth(separator),
		sign = vim.fn.strdisplaywidth(sign),
	},
}

LOCAL.length.full = LOCAL.length.separator + LOCAL.length.padding + LOCAL.length.sign
M.length = LOCAL.length.separator + LOCAL.length.padding + LOCAL.length.sign

local close_fn_cache = {}

vim.api.nvim_create_autocmd("BufDelete", {
	callback = function(opts)
		local bufnr = opts.buf
		local fn_name = close_fn_cache[bufnr]
		if fn_name then
			_G[fn_name] = nil
			close_fn_cache[bufnr] = nil
		end
	end,
})

local function close_button(buf, close_string)
	if not close_fn_cache[buf.nr] then
		local fn_name = "TablineCloseBuffer" .. buf.nr
		_G[fn_name] = function()
			require("core.ui.buffers.handler").delete(buf.nr)
			vim.cmd("redrawtabline")
		end
		close_fn_cache[buf.nr] = fn_name
	end
	return string.format("%%@v:lua.%s@%s%%X", close_fn_cache[buf.nr], close_string)
end

M.get = function()
	local function representation(buf, active)
		local p = active and LOCAL.active or LOCAL.inactive
		local button = close_button(buf, p.sign)
		return p.separator .. p.padding .. button
	end

	local function shorten(buf, remaining, right, visible)
		if remaining >= LOCAL.length.full then
			remaining = remaining - LOCAL.length.full
			visible = right and visible .. representation(buf, false) or representation(buf, false) .. visible
		elseif right and remaining >= LOCAL.length.separator then
			remaining = remaining - LOCAL.length.separator
			visible = visible .. LOCAL.inactive.separator
		elseif not right and remaining >= LOCAL.length.sign then
			remaining = remaining - LOCAL.length.sign
			visible = LOCAL.inactive.sign .. visible
		end
		return visible, remaining
	end

	return { representation = representation, shorten = shorten }
end

return M
