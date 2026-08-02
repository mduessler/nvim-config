--- Runtime toggles for lsp servers, linters and formatters.
---
--- Holds the session-only state of disabled tools and applies the side
--- effects of a toggle. The UI on top lives in core.ui.dialogs.toggle. State is
--- intentionally not persisted: every restart starts with the defaults.

local M = {}

M.kinds = { "lsp", "linter", "formatter" }

local disabled = {
	lsp = {},
	linter = {},
	formatter = {},
}

M.is_enabled = function(kind, name)
	return not disabled[kind][name]
end

--- Filters a list of tool names down to the currently enabled ones.
M.filter = function(kind, names)
	return vim.tbl_filter(function(name)
		return M.is_enabled(kind, name)
	end, names or {})
end

local function apply_lsp(name)
	vim.lsp.enable(name, M.is_enabled("lsp", name))
end

local function apply_linter(name)
	local lint = require("lint")
	if M.is_enabled("linter", name) then
		vim.schedule(function()
			lint.try_lint(M.filter("linter", lint.linters_by_ft[vim.bo.filetype] or {}))
		end)
	else
		vim.diagnostic.reset(lint.get_namespace(name))
	end
end

M.toggle = function(kind, name)
	disabled[kind][name] = not disabled[kind][name] or nil

	if kind == "lsp" then
		apply_lsp(name)
	elseif kind == "linter" then
		apply_linter(name)
	end
	-- Formatters have no active state: the filter is consulted on format.
end

local function lsp_tools(ft)
	local tools = {}
	for _, server in pairs(require("lsp.servers")) do
		local fts = vim.lsp.config[server] and vim.lsp.config[server].filetypes
		if not ft or not fts or vim.tbl_contains(fts, ft) then
			table.insert(tools, server)
		end
	end
	return tools
end

local function by_ft_tools(by_ft, ft)
	if ft then
		return vim.deepcopy(by_ft[ft] or {})
	end

	local seen = {}
	local tools = {}
	for _, names in pairs(by_ft) do
		for _, name in ipairs(names) do
			if not seen[name] then
				seen[name] = true
				table.insert(tools, name)
			end
		end
	end
	return tools
end

--- Returns the available tools per kind, optionally limited to the
--- tools that are relevant for the given filetype.
M.tools = function(ft)
	local tools = {
		lsp = lsp_tools(ft),
		linter = by_ft_tools(require("lint").linters_by_ft, ft),
		formatter = by_ft_tools(require("conform").formatters_by_ft, ft),
	}
	for _, names in pairs(tools) do
		table.sort(names)
	end
	return tools
end

return M
