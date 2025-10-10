local require_safe = require("utils.require_safe")

local colors = require_safe("core.colors")

if not colors then
	return
end

local set = vim.api.nvim_set_hl

local function statuslineHL()
	local bg = colors.ui.statusline.bg
	local fg = colors.ui.statusline.fg
	local datetime_bg = colors.ui.statusline.datetime.bg
	local function battery_hl()
		local battery_color = colors.ui.statusline.battery.bg
		set(0, "StatuslineBattery100", { bg = battery_color, fg = colors.ui.statusline.battery.fg[100], bold = true })
		set(0, "StatuslineBattery90", { bg = battery_color, fg = colors.ui.statusline.battery.fg[90], bold = true })
		set(0, "StatuslineBattery80", { bg = battery_color, fg = colors.ui.statusline.battery.fg[80], bold = true })
		set(0, "StatuslineBattery70", { bg = battery_color, fg = colors.ui.statusline.battery.fg[70], bold = true })
		set(0, "StatuslineBattery60", { bg = battery_color, fg = colors.ui.statusline.battery.fg[60], bold = true })
		set(0, "StatuslineBattery50", { bg = battery_color, fg = colors.ui.statusline.battery.fg[50], bold = true })
		set(0, "StatuslineBattery40", { bg = battery_color, fg = colors.ui.statusline.battery.fg[40], bold = true })
		set(0, "StatuslineBattery30", { bg = battery_color, fg = colors.ui.statusline.battery.fg[30], bold = true })
		set(0, "StatuslineBattery20", { bg = battery_color, fg = colors.ui.statusline.battery.fg[20], bold = true })
		set(0, "StatuslineBattery10", { bg = battery_color, fg = colors.ui.statusline.battery.fg[10], bold = true })
		set(0, "StatuslineBattery0", { bg = battery_color, fg = colors.ui.statusline.battery.fg[0], bold = true })
		set(0, "StatuslineBatterySeperator", { bg = datetime_bg, fg = battery_color })
	end

	local function branch_hl()
		local name = "StatuslineBranch"
		set(0, name .. "IsModified", { bg = colors.ui.git.modified.bg.is, fg = colors.ui.git.fg })
		set(0, name .. "NotModified", { bg = colors.ui.git.modified.bg._not, fg = colors.ui.git.fg })
		set(0, name .. "IsModifiedSeperator", { bg = colors.ui.statusline.bg, fg = colors.ui.git.modified.bg.is })
		set(0, name .. "NotModifiedSeperator", { bg = colors.ui.statusline.bg, fg = colors.ui.git.modified.bg._not })
	end

	local function datetime_hl()
		set(0, "StatuslineTime", { bg = datetime_bg, fg = colors.ui.statusline.datetime.time })
		set(0, "StatuslineDate", { bg = datetime_bg, fg = colors.ui.statusline.datetime.date })
		set(0, "StatuslineDateTimeSep", { bg = datetime_bg, fg = colors.ui.fg })
		set(0, "StatuslineDateTimeSepEnd", { bg = colors.ui.statusline.bg, fg = datetime_bg })
	end

	local function dirname_hl()
		set(0, "StatuslineDirname", { bg = colors.ui.statusline.dirname.bg, fg = colors.ui.statusline.dirname.fg })
		set(0, "StatuslineDirnameSeperator", { bg = colors.ui.statusline.bg, fg = colors.ui.statusline.dirname.bg })
		set(
			0,
			"StatuslineDirnameSeperatorIsModified",
			{ bg = colors.ui.git.modified.bg.is, fg = colors.ui.statusline.dirname.bg }
		)
		set(
			0,
			"StatuslineDirnameSeperatorNotModified",
			{ bg = colors.ui.git.modified.bg._not, fg = colors.ui.statusline.dirname.bg }
		)
	end

	local function diagnostics_hl()
		set(0, "StatuslineError", { bg = bg, fg = colors.ui.diagnostics.error })
		set(0, "StatuslineWarning", { bg = bg, fg = colors.ui.diagnostics.warning })
		set(0, "StatuslineHint", { bg = bg, fg = colors.ui.diagnostics.hint })
		set(0, "StatuslineInfo", { bg = bg, fg = colors.ui.diagnostics.info })
	end

	local function encoding_hl()
		set(0, "StatuslineEncoding", { bg = bg, fg = fg })
		set(0, "StatuslineEncodingSeperator", { bg = bg, fg = fg })
	end

	local function mode_hl()
		for key in pairs(colors.ui.statusline.mode.bg) do
			set(
				0,
				"StatuslineMode" .. key,
				{ bg = colors.ui.statusline.mode.bg[key], fg = colors.ui.statusline.mode.fg, bold = true }
			)
		end
	end

	local function position_hl()
		set(0, "StatuslinePosition", { bg = bg, fg = fg })
		set(0, "StatuslinePositionSep", { bg = bg, fg = fg })
	end

	local function root_hl()
		set(0, "StatuslineRoot", { bg = colors.ui.statusline.root.bg, fg = colors.ui.statusline.root.fg })
		set(0, "StatuslineRootSeperator", { bg = colors.ui.statusline.dirname.bg, fg = colors.ui.statusline.root.bg })
		set(0, "StatuslineRootSeperatorNoDir", { bg = colors.ui.statusline.bg, fg = colors.ui.statusline.root.bg })
		set(
			0,
			"StatuslineRootSeperatorIsModified",
			{ bg = colors.ui.git.modified.bg.is, fg = colors.ui.statusline.root.bg }
		)
		set(
			0,
			"StatuslineRootSeperatorNotModified",
			{ bg = colors.ui.git.modified.bg._not, fg = colors.ui.statusline.root.bg }
		)
	end

	local statusline_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
	set(0, "StatuslineInvisible", { bg = statusline_hl.bg, fg = statusline_hl.bg })

	battery_hl()
	branch_hl()
	datetime_hl()
	dirname_hl()
	diagnostics_hl()
	encoding_hl()
	mode_hl()
	position_hl()
	root_hl()
end

local function tablineHL()
	local function boundary_hl()
		set(0, "TabLineBoundaryMore", { bg = colors.tabline.bg.inactive, fg = colors.tabline.fg.inactive })
		set(0, "TabLineBoundaryPadding", { bg = colors.tabline.bg.inactive, fg = colors.tabline.bg.inactive })
		set(0, "TabLineBoundarySeparator", { bg = colors.tabline.bg.inactive, fg = colors.tabline.bg.default })
		set(0, "TabLineBoundaryModified", { bg = colors.tabline.bg.inactive, fg = colors.ui.modified.is_modified })
		set(0, "TabLineBoundaryClose", { bg = colors.tabline.bg.inactive, fg = colors.tabline.fg.default })
		set(0, "TabLineBoundaryCloseSeparator", { bg = colors.tabline.bg.inactive, fg = colors.tabline.fg.default })
	end
	local function modifed_hl()
		local active = { bg = colors.tabline.bg.active, fg = colors.ui.modified.is_modified }
		local inactive = { bg = colors.tabline.bg.inactive, fg = colors.ui.modified.is_modified }
		set(0, "TabLineModifiedActiveIsNotModified", active)
		set(0, "TabLineModifiedInActiveIsNotModified", inactive)
		set(0, "TabLineModifiedActiveIsModified", active)
		set(0, "TabLineModifiedInActiveIsModified", inactive)
		set(0, "TabLineModifiedActiveIsReadonly", active)
		set(0, "TabLineModifiedInActiveIsReadonly", inactive)
	end

	local function close_hl()
		set(0, "TabLineCloseActive", { bg = colors.tabline.bg.active, fg = colors.tabline.fg.close })
		set(0, "TabLineCloseSepActive", { bg = colors.tabline.bg.active, fg = colors.tabline.fg.default })
		set(0, "TabLineCloseInactive", { bg = colors.tabline.bg.inactive, fg = colors.tabline.fg.close })
		set(0, "TabLineCloseSepInactive", { bg = colors.tabline.bg.inactive, fg = colors.tabline.fg.default })
	end

	local function padding_hl()
		set(0, "TabLinePadding", { bg = colors.tabline.bg.default, fg = colors.tabline.bg.default })
		set(0, "TabLinePaddingActive", { bg = colors.tabline.bg.active, fg = colors.tabline.bg.active })
		set(0, "TabLinePaddingInactive", { bg = colors.tabline.bg.inactive, fg = colors.tabline.bg.inactive })
	end

	local function name_hl()
		set(0, "TabLineNameInactive", { bg = colors.tabline.bg.inactive, fg = colors.tabline.fg.inactive })
		set(0, "TabLineIconInactive", { bg = colors.tabline.bg.inactive, fg = colors.tabline.fg.inactive })
		set(0, "TabLineNameActive", { bg = colors.tabline.bg.active, fg = colors.tabline.fg.active })
	end

	local function seperator_hl()
		set(0, "TabLineSepActive", { fg = colors.tabline.bg.default, bg = colors.tabline.bg.active, bold = true })
		set(0, "TabLineSepInactive", { fg = colors.tabline.bg.default, bg = colors.tabline.bg.inactive, bold = true })
	end

	padding_hl()
	seperator_hl()
	name_hl()
	boundary_hl()
	modifed_hl()
	close_hl()
end

local function winbar_hl()
	local function modifed_hl()
		set(0, "WinbarIsModified", { bg = colors.ui.winbar.bg, fg = colors.ui.modified.is_modified })
		set(0, "WinbarIsReadonly", { bg = colors.ui.winbar.bg, fg = colors.ui.modified.is_readonly })
	end

	local function diagnostics_hl()
		set(0, "WinbarError", { bg = colors.ui.winbar.bg, fg = colors.ui.diagnostics.error })
		set(0, "WinbarWarning", { bg = colors.ui.winbar.bg, fg = colors.ui.diagnostics.warning })
		set(0, "WinbarHint", { bg = colors.ui.winbar.bg, fg = colors.ui.diagnostics.hint })
		set(0, "WinbarInfo", { bg = colors.ui.winbar.bg, fg = colors.ui.diagnostics.info })
	end

	local function position()
		set(0, "WinbarPosition", { bg = colors.ui.winbar.bg, fg = colors.ui.fg, bold = true })
	end

	local function changes()
		set(0, "WinbarAdd", { bg = colors.ui.winbar.bg, fg = colors.ui.git.changes.added })
		set(0, "WinbarDel", { bg = colors.ui.winbar.bg, fg = colors.ui.git.changes.deleted })
	end

	local function file()
		set(0, "WinbarPath", { bg = colors.ui.winbar.bg, fg = colors.ui.fg, bold = true })
		set(0, "WinbarPathIconConfig", { bg = colors.ui.winbar.bg, fg = colors.ui.winbar.file.config, bold = true })
		set(0, "WinbarPathIconGit", { bg = colors.ui.winbar.bg, fg = colors.ui.winbar.file.git, bold = true })
		set(0, "WinbarPathIconHome", { bg = colors.ui.winbar.bg, fg = colors.ui.winbar.file.home, bold = true })
		set(0, "WinbarPathIconNvim", { bg = colors.ui.winbar.bg, fg = colors.ui.winbar.file.nvim, bold = true })
		set(0, "WinbarPathIconRoot", { bg = colors.ui.winbar.bg, fg = colors.ui.winbar.file.root, bold = true })
	end
	set(0, "Winbar", { bg = colors.ui.winbar.bg, fg = colors.ui.fg })
	set(0, "WinbarNC", { bg = colors.ui.winbar.bg, fg = colors.ui.fg })

	set(0, "WinbarIconActive", { bg = colors.ui.winbar.bg, fg = colors.ui.winbar.active })
	set(0, "WinbarClose", { bg = colors.ui.winbar.bg, fg = colors.ui.quit })
	set(0, "WinbarPadding", { bg = colors.ui.winbar.bg, fg = colors.ui.winbar.bg })
	set(0, "WinbarSeperator", { bg = colors.ui.winbar.bg, fg = colors.ui.fg })

	modifed_hl()
	diagnostics_hl()
	position()
	changes()
	file()
end

local function vim_ui_hl()
	vim.api.nvim_set_hl(0, "VimUiInputStartIcon", { fg = colors.default.green.light })
end

statuslineHL()
tablineHL()
winbar_hl()
vim_ui_hl()
