vim.cmd("set encoding=UTF-8")

package.path = package.path .. ";" .. vim.fn.expand("~/.local/share/luarocks/share/lua/5.1/?.lua")
package.path = package.path .. ";" .. vim.fn.expand("~/.local/share/luarocks/share/lua/5.1/?/init.lua")

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

require("core.keymaps")
require("core")
