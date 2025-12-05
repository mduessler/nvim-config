vim.cmd("set encoding=UTF-8")

-- TODO: Write pathes dynamic.
local home = os.getenv("HOME")
package.path = home
	.. "/.local/share/luarocks/share/lua/5.1/?.lua;"
	.. home
	.. "/.local/share/luarocks/share/lua/5.1/?/init.lua;"
	.. package.path

package.cpath = home
	.. "/.local/share/luarocks/lib/lua/5.1/?.so;"
	.. home
	.. "/.local/share/luarocks/lib64/lua/5.1/?.so;"
	.. package.cpath

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

-- vim.notify = require("notify")

require("core.keymaps")
require("core")

require("utils.update.handler")
