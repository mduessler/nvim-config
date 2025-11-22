local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end

local M = {
	signs = {
		not_modified = signs.ui.modified.isNotModified,
		default = signs.ui.modified.isModified,
		readonly = signs.ui.modified.isReadonly,
	},
}

M.length = {
	not_modified = vim.fn.strdisplaywidth(M.signs.not_modified),
	default = vim.fn.strdisplaywidth(M.signs.default),
	readonly = vim.fn.strdisplaywidth(M.signs.readonly),
}

M.length.max = math.max(M.length.not_modified, M.length.default, M.length.readonly)

M.is_readonly = function(bufnr)
	return not vim.api.nvim_get_option_value("modifiable", { buf = bufnr })
		or vim.api.nvim_get_option_value("readonly", { buf = bufnr })
end

M.representation = function(bufnr)
	if not vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
		return M.signs.not_modified
	end
	return M.is_readonly(bufnr) and M.signs.readonly or M.signs.default
end

return M
