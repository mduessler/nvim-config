local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")

local M = {}

local function get_diagnostic(bufnr, severity, sign)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return ""
	end
	local diagnostics = vim.diagnostic.get(bufnr, { severity = severity })
	if #diagnostics > 0 then
		return table.concat({ sign, #diagnostics }, " ")
	end
	return ""
end

M.errors = function(bufnr)
	return get_diagnostic(bufnr, vim.diagnostic.severity.ERROR, signs.diagnostics.error)
end

M.warnings = function(bufnr)
	return get_diagnostic(bufnr, vim.diagnostic.severity.WARN, signs.diagnostics.warning)
end

M.hints = function(bufnr)
	return get_diagnostic(bufnr, vim.diagnostic.severity.HINT, signs.diagnostics.hint)
end

M.infos = function(bufnr)
	return get_diagnostic(bufnr, vim.diagnostic.severity.INFO, signs.diagnostics.info)
end

return M
