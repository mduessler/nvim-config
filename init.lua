vim.cmd("set encoding=UTF-8")

-- Remove Neovim 0.10 default keymaps you don't want
local status, utils = pcall(require, "utils.key")

if status then
	local default_keys = { "gcc", "gc", "Y", "gx" }
	for _, key in ipairs(default_keys) do
		utils.del("n", key)
	end
end

vim.g.mapleader = " "

require("config")

vim.notify = require("notify")

require("core.keymaps")
require("core")
