local require_safe = require("utils.require_safe")
local signs = require_safe("config.signs")

if not signs then
	return
end

local isNotModified = signs.ui.modified.isNotModified
local isModified = signs.ui.modified.isModified
local isReadonly = signs.ui.modified.isReadonly

local M = {}

local function get_length()
	local isNotModified_length = vim.fn.strdisplaywidth(isNotModified)
	local isModified_length = vim.fn.strdisplaywidth(isModified)
	local isReadonly_length = vim.fn.strdisplaywidth(isReadonly)

	return math.max(isNotModified_length, isModified_length, isReadonly_length)
end

M.length = get_length()

M.get_representation = function(bufnr)
	if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
		if
			not vim.api.nvim_get_option_value("modifiable", { buf = bufnr })
			or vim.api.nvim_get_option_value("readonly", { buf = bufnr })
		then
			return isReadonly
		end
		return isModified
	end
	return isNotModified
end

return M
