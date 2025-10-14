local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")
local project = require_safe("core.ui.utils.project")
local windows = require_safe("core.ui.windows.handler")

local mode = require_safe("core.ui.components.statusline.mode")
local root = require_safe("core.ui.components.statusline.root")
local dirname = require_safe("core.ui.components.statusline.dirname")
local git = require_safe("core.ui.components.statusline.git")
local file = require_safe("core.ui.components.statusline.file")
local position = require_safe("core.ui.components.statusline.position")

local my_os = require_safe("core.ui.components.statusline.os")
local battery = require_safe("core.ui.components.statusline.battery")
local datetime = require_safe("core.ui.components.statusline.datetime")
local diagnostic = require_safe("core.ui.components.statusline.diagnostic")
local encoding = require_safe("core.ui.components.statusline.encoding")

if
	not (
		buffers
		and project
		and windows
		and mode
		and root
		and dirname
		and git
		and file
		and position
		and my_os
		and battery
		and datetime
		and diagnostic
		and encoding
	)
then
	return
end

local M = {}

M.render = function()
	local i = buffers.get_active_buffer_index()
	local buf = buffers.items[i]
	local win = windows.get(vim.api.nvim_get_current_win())

	local current_mode = mode.get()
	local current_root = root.get(buf)
	local current_dirname = dirname.get(buf)
	local current_git = git.get()
	local current_file = file.get(buf)
	local current_position = position.get(win)

	local current_os = my_os.get()
	local current_battery = battery.get()
	local current_datetime = datetime.get()
	local current_encoding = encoding.get(buf)
	local current_diagnostic = diagnostic.get()

	local remaining = vim.api.nvim_win_get_width(0)

	local function insert_component(components, current)
		if remaining > current.length then
			components[#components + 1] = current.component
			remaining = remaining - current.length
		else
			remaining = -1
		end
	end

	local function render_left_components()
		local components = {}
		insert_component(components, current_mode)
		insert_component(components, current_root)
		insert_component(components, current_dirname)
		insert_component(components, current_git)
		insert_component(components, current_file)
		insert_component(components, current_position)

		return table.concat(components)
	end

	local function render_right_components()
		local components = {}
		insert_component(components, current_diagnostic)
		insert_component(components, current_encoding)
		insert_component(components, current_datetime)
		insert_component(components, current_battery)
		insert_component(components, current_os)

		return table.concat(components)
	end
	return render_left_components() .. "%=" .. render_right_components()
end

M.setup = function()
	project.setup(vim.fn.expand("%:p"))

	vim.o.laststatus = 3
	vim.o.statusline = "%!v:lua.require('core.ui.statusline').render()"

	local timer = vim.loop.new_timer()

	timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			buffers.update()
			vim.cmd("redrawstatus")
		end)
	)
end

return M
