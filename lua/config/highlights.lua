local require_safe = require("utils.require_safe")

local colors = require_safe("config.colors")

if not colors then
	return
end

local set = vim.api.nvim_set_hl

local function default_colors()
	local function hl(name, hex)
		set(0, name, { fg = hex })
	end
	hl("MyBlack", colors.default.black)
	hl("MyWhite", colors.default.white)
	hl("MyGrey", colors.default.grey)
	hl("MyRed", colors.default.red)
	hl("MyPink", colors.default.pink)
	hl("MyBlue", colors.default.blue.default)
	hl("MyBlueLight", colors.default.blue.light)
	hl("MyGreen", colors.default.green.default)
	hl("MyGreenLight", colors.default.green.light)
	hl("MyYellow", colors.default.yellow)
	hl("MyOrange", colors.default.orange)
	hl("MyPurple", colors.default.purple)
	hl("MyCyan", colors.default.cyan)
end

default_colors()
