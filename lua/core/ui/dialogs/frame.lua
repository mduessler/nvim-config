--- Box drawing helpers for framed dialog content.

local M = {}

M.border = {
	top_left = "╭",
	top_right = "╮",
	bottom_left = "╰",
	bottom_right = "╯",
	horizontal = "─",
	vertical = "│",
}

M.top = function(width)
	return M.border.top_left .. string.rep(M.border.horizontal, width - 2) .. M.border.top_right
end

M.bottom = function(width)
	return M.border.bottom_left .. string.rep(M.border.horizontal, width - 2) .. M.border.bottom_right
end

--- Pads the content to the inner width and closes the box on the right.
--- An optional right part is aligned to the right border of the box.
M.framed = function(content, width, right)
	right = right or ""
	local fill = width - 4 - vim.fn.strdisplaywidth(content) - vim.fn.strdisplaywidth(right)
	return M.border.vertical
		.. " "
		.. content
		.. string.rep(" ", math.max(fill, 0))
		.. right
		.. " "
		.. M.border.vertical
end

return M
