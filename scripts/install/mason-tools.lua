pcall(require, "mason").setup()
local ok, mti = pcall(require, "mason-tool-installer")
if not ok then
	os.exit(1)
end

mti.update({ run_on_start = true })

local timeout = 600000 -- 10 minutes in ms
vim.wait(timeout, function()
	local pending = false
	for _, pkg_name in ipairs(mti.settings.ensure_installed or {}) do
		local pkg = require("mason-registry").get_package(pkg_name)
		if not pkg:is_installed() then
			pending = true
			break
		end
	end
	return not pending
end, 1000)
