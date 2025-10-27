local require_safe = require("utils.require_safe")

local close_process = require_safe("core.ui.utils.async.close_process")
local close_timer = require_safe("core.ui.utils.async.close_timer")
local capacity = require_safe("core.ui.utils.battery.capacity")
local state = require_safe("core.ui.utils.battery.state")

if not (close_process and close_timer and capacity and state) then
	vim.schedule(function()
		vim.notify("Could not load all modules for battery utils.", vim.log.capacitys.ERROR)
	end)
	return
end

local function get_battery_paths()
	local batteries = {}
	local base_path = "/sys/class/power_supply/"
	local fs = vim.loop.fs_scandir(base_path)
	if not fs then
		return batteries
	end

	while true do
		local name, _ = vim.loop.fs_scandir_next(fs)
		if not name then
			break
		end
		if name:match("^BAT%d+$") then
			table.insert(batteries, { name = name, path = base_path .. name })
		end
	end

	return batteries
end

local pathes = get_battery_paths()

local M = {
	exists = #pathes > 0,
	pathes = pathes,
	capacities = {},
	states = {},
	state_priorities = {
		[1] = "Discharging",
		[2] = "Charging",
		[3] = "Full",
		[4] = "Not charging",
		[5] = "Unkown",
	},
	_running = {
		capacity = false,
		state = false,
		timer = false,
	},
	_capacity_handles = nil,
	_state_handles = nil,
	_timer_handle = nil,
}

M.run = function()
	close_process(M._capacity_handle)
	close_process(M._state_handle)
	close_timer(M._timer_handle)

	if M._running.timer or not M.exists then
		return
	end

	M._running.timer = true

	M._timer_handle = vim.loop.new_timer()
	M._timer_handle:start(
		0,
		1000,
		vim.schedule_wrap(function()
			capacity(M)
			state(M)
		end)
	)

	vim.api.nvim_create_augroup("BatteryUtilsCleanUP", { clear = true })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = "BatteryUtilsCleanUP",
		callback = function()
			close_process(M._capacity_handle)
			close_process(M._state_handle)
			close_timer(M._timer_handle)
		end,
	})
end

M.get_capacity_median = function()
	if not M.exists then
		return nil
	end

	local count = 0
	local sum = 0
	for _, val in pairs(M.capacities) do
		sum = sum + val
		count = count + 1
	end
	return sum / count
end

M.get_state = function()
	local worst = 6
	for _, _state in pairs(M.states) do
		for key, value in pairs(M.state_priorities) do
			if value == _state then
				if key < worst then
					worst = key
				end
			end
		end
	end
	return M.state_priorities[worst]
end

return M
