local require_safe = require("utils.require_safe")

local modified = require_safe("core.ui.utils.modified")
local str = require_safe("utils.str")
local signs = require_safe("config.signs")

if not (modified and str and signs) then
	return
end

local function pad_new(hl_group, sign_name, active)
	local pad_hl = active and "TabLinePaddingActive" or "TabLinePaddingInactive"
	if modified.length.max > modified.length[sign_name] then
		local pad = string.rep(signs.ui.padding, modified.length.max - modified.length[sign_name])
		return str.highlight(hl_group, modified.signs[sign_name]) .. str.highlight(pad_hl, pad)
	end
	return str.highlight(hl_group, modified.signs[sign_name])
end

local LOCAL = {
	active = {
		not_modified = pad_new("TabLineModifiedActiveIsNotModified", "not_modified", true),
		modified = pad_new("TabLineModifiedActiveIsModified", "default", true),
		readonly = pad_new("TabLineModifiedActiveIsReadonly", "readonly", true),
	},
	inactive = {
		not_modified = pad_new("TabLineModifiedInactiveIsNotModified", "not_modified", false),
		modified = pad_new("TabLineModifiedInactiveIsModified", "default", false),
		readonly = pad_new("TabLineModifiedInactiveIsReadonly", "readonly", false),
	},
}

local M = { length = modified.length.max }

M.get = function()
	local function representation(buf, active)
		local is_modiefied = vim.api.nvim_get_option_value("modified", { buf = buf.nr })
		if not is_modiefied then
			return active and LOCAL.active.not_modified or LOCAL.inactive.not_modified
		end
		if modified.is_readonly(buf.nr) then
			return active and LOCAL.active.readonly or LOCAL.inactive.readonly
		end
		return active and LOCAL.active.modified or LOCAL.inactive.modified
	end

	return { length = modified.length.max, representation = representation }
end

return M
