local require_safe = require("utils.require_safe")

local changes = require_safe("core.ui.buffers.changes")
local devicons = require_safe("nvim-web-devicons")
local diagnostic = require_safe("core.ui.buffers.diagnostic")
local dir = require_safe("core.ui.utils.directory")
local modified = require_safe("core.ui.utils.modified")
local project = require_safe("core.ui.utils.project")
local signs = require("config.signs")

if not (changes and devicons and diagnostic and dir and modified and project and signs) then
	return
end

local function set_file(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	local filename = vim.fn.fnamemodify(path, ":t")
	local icon, color = devicons.get_icon_color(filename, nil, { default = true })
	return {
		name = filename,
		path = path,
		icon = icon,
		color = color,
		length = {
			name = vim.fn.strdisplaywidth(filename),
			icon = vim.fn.strdisplaywidth(icon),
		},
	}
end

local function set_modified(bufnr)
	return {
		value = vim.api.nvim_get_option_value("modified", { buf = bufnr }),
		representation = modified.representation(bufnr),
		length = modified.length.max,
	}
end

local function set_diagnostics(bufnr)
	local function get_diaagnostic(severity, sign)
		local cnt = vim.diagnostic.get(bufnr, { severity = severity })
		return {
			sign = sign,
			cnt = #cnt,
			size = {
				sign = vim.fn.strdisplaywidth(sign),
				cnt = vim.fn.strdisplaywidth(tostring(#cnt)),
			},
		}
	end

	return {
		error = get_diaagnostic(vim.diagnostic.severity.ERROR, signs.diagnostics.error),
		warning = get_diaagnostic(vim.diagnostic.severity.WARN, signs.diagnostics.warning),
		hint = get_diaagnostic(vim.diagnostic.severity.HINT, signs.diagnostics.hint),
		info = get_diaagnostic(vim.diagnostic.severity.INFO, signs.diagnostics.info),
	}
end

local function set_encoding(bufnr)
	local representation = vim.bo[bufnr].fileencoding
	representation = (representation ~= "" and representation) or vim.o.encoding
	return {
		representation = representation,
		size = vim.fn.strdisplaywidth(representation),
	}
end

local function set_changes(self)
	local name = self.file.name
	local path = self.file.path
	if not project.is_git_repo or not dir.is_subpath(path, project.root) then
		return nil
	end
	path = dir.get_subdir(path, project.root) .. name
	if project.git.changes[path] ~= nil then
		return project.git.changes[path]
	end
	return { added = 0, deleted = 0 }
end

local function buffer(bufnr)
	local self = {
		nr = bufnr,
		last_active = true,
		file = set_file(bufnr),
		modified = set_modified(bufnr),
		diagnostics = set_diagnostics(bufnr),
		encoding = set_encoding(bufnr),
	}

	self.git = {
		changes = set_changes(self),
	}

	self.update = function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end
		self.modified = set_modified(bufnr)
		self.diagnostics = set_diagnostics(bufnr)
		self.encoding = set_encoding(bufnr)
		self.git.changes = changes.get(self.file.path, self.file.name)
	end

	return self
end

return buffer
