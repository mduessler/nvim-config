local require_safe = require("lua.utils.require_safe")
local ls = require_safe("lua.lsp.servers")

for server in ls do
	vim.cmd("MasonInstall " .. tostring(server))
	print("Installed mason Language Server " .. server)
end
print("Installed servers")
vim.cmd("MasonToolsInstallSync")
print("Installed Mason tools")
vim.cmd("qa!")
-- mti.update({ run_on_start = true })
--
-- local timeout = 600000 -- 10 minutes in ms
-- vim.wait(timeout, function()
-- 	local pending = false
-- 	for _, pkg_name in ipairs(mti.settings.ensure_installed or {}) do
-- 		local pkg = require("mason-registry").get_package(pkg_name)
-- 		if not pkg:is_installed() then
-- 			pending = true
-- 			break
-- 		end
-- 	end
-- 	return not pending
-- end, 1000)
