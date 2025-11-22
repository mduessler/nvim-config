local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")
local str = require_safe("utils.str")
local signs = require_safe("config.signs")

if not (buffers and str and signs) then
	return
end

local close = signs.ui.tabline.close.sign
local more_left = signs.ui.tabline.boundaries.more.left
local more_right = signs.ui.tabline.boundaries.more.right
local modified = signs.ui.modified.isModified
local padding = signs.ui.padding
local separator_close = signs.ui.tabline.close.separator
local separator_left = signs.ui.separator.left.line
local separator_right = signs.ui.separator.right.line

local parts = {
	close = str.highlight("TabLineCloseInactive", close),
	length = {
		close = vim.fn.strdisplaywidth(close),
		modified = vim.fn.strdisplaywidth(modified),
		more = {
			left = vim.fn.strdisplaywidth(more_left),
			right = vim.fn.strdisplaywidth(more_right),
		},
		padding = vim.fn.strdisplaywidth(padding),
		separator = {
			left = vim.fn.strdisplaywidth(separator_left),
			right = vim.fn.strdisplaywidth(separator_right),
			close = vim.fn.strdisplaywidth(separator_close),
		},
	},
	modified = { sign = str.highlight("TabLineModifiedInActiveIsModified", modified) },
	more = {
		left = { sign = str.highlight("TabLineBoundaryMore", more_left) },
		right = { sign = str.highlight("TabLineBoundaryMore", more_right) },
	},
	padding = str.highlight("TabLinePaddingInactive", padding),
	separator = {
		close = str.highlight("TabLineCloseSepInactive", separator_close),
		left = str.highlight("TabLineBoundarySeparator", separator_left),
		right = str.highlight("TabLineBoundarySeparator", separator_right),
	},
}

parts.length.full = {
	left = 5 * parts.length.padding
		+ parts.length.close
		+ parts.length.separator.close
		+ parts.length.more.left
		+ parts.length.modified
		+ parts.length.separator.left,
	right = 5 * parts.length.padding
		+ parts.length.separator.right
		+ parts.length.modified
		+ parts.length.more.right
		+ parts.length.separator.close
		+ parts.length.close,
}

parts.more.left.padding = str.highlight("TabLinePaddingInactive", string.rep(padding, parts.length.more.left))
parts.more.right.padding = str.highlight("TabLinePaddingInactive", string.rep(padding, parts.length.more.right))
parts.modified.padding = str.highlight("TabLinePaddingInactive", string.rep(padding, parts.length.modified))

local M = {}

local function get_modified(lower, upper)
	for i = lower or 1, upper do
		if buffers.items[i] ~= nil and buffers.items[i].modified.value then
			return parts.modified.sign
		end
	end
	return parts.padding
end

local function padding_or_more(is_left, boundary)
	if is_left then
		if boundary > 1 then
			return parts.more.left.sign
		end
		return parts.padding
	end
	return boundary < #buffers.items and parts.more.right.sign or parts.padding
end

M.get = function()
	local function left(boundary)
		return table.concat({
			"",
			parts.close,
			parts.separator.close,
			padding_or_more(true, boundary),
			"",
			get_modified(1, boundary - 1),
		}, parts.padding) .. parts.separator.right
	end
	local function right(boundary)
		return parts.separator.left
			.. table.concat({
				get_modified(boundary + 1, #buffers.items),
				"",
				padding_or_more(false, boundary),
				parts.separator.close,
				parts.close,
				"",
			}, parts.padding)
	end

	return { length = parts.length, left = left, right = right }
end

return M
