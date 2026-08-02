local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy")

local specs = {
	{ import = "plugins" },
}
for name, kind in vim.fs.dir(vim.fn.stdpath("config") .. "/lua/plugins") do
	if kind == "directory" then
		table.insert(specs, { import = "plugins." .. name })
	end
end

lazy.setup({
	spec = specs,
	rocks = {
		enabled = false,
	},
	ui = {
		border = "rounded",
	},
})
