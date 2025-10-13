local require_safe = require("utils.require_safe")

local battery = require_safe("core.ui.utils.battery.handler")
local signs = require_safe("config.signs")
local str = require_safe("utils.str")

if not (battery and signs and str) then
	return
end

local LOCAL = {
	hl = {
		seperator = str.highlight("StatuslineBatterySeperator", signs.ui.seperator.left.triangle),
	},
	signs = {
		padding = signs.ui.padding,
	},
}

LOCAL.length = {
	seperator = vim.fn.strdisplaywidth(LOCAL.signs.seperator),
}

for _, level in ipairs({ 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0 }) do
	LOCAL[level] = {
		signs = {
			charging = signs.ui.statusline.battery.charging[level],
			discharging = signs.ui.statusline.battery.discharging[level],
			full = signs.ui.statusline.battery.full,
			unknown = signs.ui.statusline.battery.unknown,
			["not charging"] = signs.ui.statusline.battery["not charging"],
		},
		hl = "StatuslineBattery" .. level,
	}
end

local M = {}

M.get = function()
	if not battery._running.timer then
		battery.run()
	end

	local level = battery.get_capacity_median()
	if level == nil then
		return {
			length = 0,
			component = "",
		}
	end
	local state = battery.get_state() or ""
	state = state:lower()
	local _battery = LOCAL[math.floor(level / 10) * 10]

	if _battery == nil or _battery.signs[state] == nil then
		return {
			length = 0,
			component = "",
		}
	end

	local content = table.concat({ "", _battery.signs[state], level .. "%%", "" }, LOCAL.signs.padding)
	local length = vim.fn.strdisplaywidth(content)

	return {
		length = length + LOCAL.length.seperator,
		component = LOCAL.hl.seperator .. str.highlight(_battery.hl, content),
	}
end

return M
