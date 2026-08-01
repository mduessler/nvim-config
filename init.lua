vim.cmd("set encoding=UTF-8")

-- Remove Neovim 0.10 default keymaps you don't want. Which of them exist
-- depends on the nvim version, so only delete the ones that are present.
local utils = require("utils.key")

local default_keys = { "gcc", "gc", "Y", "gx" }
for _, key in ipairs(default_keys) do
	if vim.fn.maparg(key, "n") ~= "" then
		utils.del("n", key)
	end
end

vim.g.mapleader = " "

require("config")

vim.notify = require("notify")

require("core.keymaps")
require("core")
