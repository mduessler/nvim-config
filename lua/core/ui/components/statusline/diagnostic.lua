local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (buffers and signs and str) then
	return
end

local LOCAL = {
	hl = {
		error = "StatuslineError",
		warning = "StatuslineWarning",
		hint = "StatuslineHint",
		info = "StatuslineInfo",
		padding = str.highlight("StatuslinePadding", signs.ui.padding),
	},
	signs = {
		error = signs.diagnostics.error,
		hint = signs.diagnostics.hint,
		info = signs.diagnostics.info,
		warning = signs.diagnostics.warning,
		padding = signs.ui.padding,
	},
}

LOCAL.length = {
	padding = vim.fn.strdisplaywidth(signs.ui.padding),
}

local M = {}

M.get = function()
	local components = {}
	local keys = { "error", "warning", "info", "hint" }
	local diagnostics = {}
	for _, key in ipairs(keys) do
		diagnostics[key] = 0
	end
	for _, buf in ipairs(buffers.items) do
		if buf ~= nil then
			for _, key in ipairs(keys) do
				diagnostics[key] = diagnostics[key] + buf.diagnostics[key].cnt
			end
		end
	end

	components[1] = LOCAL.signs.padding
	local length = LOCAL.length.padding
	for _, key in ipairs(keys) do
		local dia = table.concat({ LOCAL.signs[key], diagnostics[key] }, LOCAL.signs.padding)
		components[#components + 1] = str.highlight(LOCAL.hl[key], dia)
		length = vim.fn.strdisplaywidth(dia)
	end
	components[#components + 1] = LOCAL.signs.padding
	length = length + LOCAL.length.padding
	return { length = length + #components - 1, component = table.concat(components, LOCAL.hl.padding) }
end

return M
