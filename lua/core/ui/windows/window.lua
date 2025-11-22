local require_safe = require("utils.require_safe")

local buffers = require_safe("core.ui.buffers.handler")

if not buffers then
	return
end

local function window(winid)
	local self = { id = winid, position = { row = 1, col = 1 } }

	local function position()
		local buf = vim.api.nvim_get_current_buf()
		if vim.bo[buf].buftype ~= "" or vim.bo[buf].buflisted == false or vim.bo[buf].modifiable == false then
			return ""
		end
		self.position.row, self.position.col = unpack(vim.api.nvim_win_get_cursor(self.id))
		self.position.col = self.position.col + 1
	end

	position()

	self.position_str = function()
		position()
		return string.format("%d:%d", self.position.row, self.position.col)
	end

	self.buf = function()
		if not vim.api.nvim_win_is_valid(self.id) then
			return nil
		end
		local bufnr = vim.api.nvim_win_get_buf(self.id)
		return buffers.get(bufnr)
	end

	return self
end

return window
