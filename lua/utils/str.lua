local M = {}

M.highlight = function(hl_group, str)
	return "%#" .. hl_group .. "#" .. str .. "%*"
end

M.endswith = function(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

return M
