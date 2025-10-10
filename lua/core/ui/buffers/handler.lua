local require_safe = require("utils.require_safe")

local buffer = require_safe("core.ui.buffers.buffer")

if not buffer then
	return
end

local M = { items = {} }

local function valid_buffer(bufnr)
	local buftype = vim.bo[bufnr].buftype
	local bufhidden = vim.bo[bufnr].bufhidden

	if buftype ~= "" or bufhidden ~= "" then
		return false
	end
	if not vim.api.nvim_buf_is_loaded(bufnr) or vim.fn.buflisted(bufnr) ~= 1 then
		return false
	end

	return true
end

local function sort(a, b)
	if a.file.path == nil then
		return false
	end
	if b.file.path == nil then
		return true
	end
	return a.file.path < b.file.path
end

local function buffer_exists(bufnr)
	for _, buf in ipairs(M.items) do
		if buf.nr == bufnr then
			return true
		end
	end
	return false
end

M.create = function(bufnr)
	if buffer_exists(bufnr) then
		return M.get(bufnr)
	end
	if not valid_buffer(bufnr) then
		return
	end
	local new = buffer(bufnr)
	M.switch_last_active()
	table.insert(M.items, new)
	table.sort(M.items, sort)
	return new
end

M.delete = function(bufnr)
	_G["CloseBuffer" .. bufnr] = nil

	if #M.items == 1 then
		vim.cmd("enew")
		M.items = {}
		M.create(vim.api.nvim_get_current_buf())
	else
		for i, buf in ipairs(M.items) do
			if buf.nr == bufnr then
				table.remove(M.items, i)
				break
			end
		end
	end

	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
end

M.get = function(bufnr)
	for _, buf in ipairs(M.items) do
		if buf.nr == bufnr then
			return buf
		end
	end
	return nil
end

M.get_active_buffer_index = function()
	local bufnr = vim.api.nvim_get_current_buf()
	if not valid_buffer(bufnr) then
		return 0
	end
	for i, buf in ipairs(M.items) do
		if buf.nr == bufnr then
			return i
		end
	end
	return 0
end

local function switch_buffer(step)
	local i = M.get_active_buffer_index()
	local new = ((i - 1 + step) % #M.items) + 1
	return M.items[new]
end

M.next = function()
	return switch_buffer(1)
end

M.prev = function()
	return switch_buffer(-1)
end

M.switch_last_active = function()
	if M.get_active_buffer_index() > 0 then
		for _, buf in ipairs(M.items) do
			buf.last_active = buf.nr == vim.fn.bufnr("#")
		end
	end
end

M.update = function()
	for _, buf in ipairs(M.items) do
		if vim.api.nvim_buf_is_valid(buf.nr) then
			buf.update()
		else
			M.delete(buf.nr)
		end
	end
end

return M
