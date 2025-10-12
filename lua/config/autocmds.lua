vim.api.nvim_create_autocmd("User", {
	pattern = "LazySync",
	callback = function()
		if #vim.api.nvim_list_uis() == 0 then -- headless
			print("Do nothing to install mason servers?")
			-- local require_safe = require("utils.require_safe")
			-- local servers = require_safe("lsp.servers")
			-- if not servers then
			-- 	return
			-- end
			-- for key, _ in ipairs(servers) do
			-- 	vim.cmd("MasonInstall " .. key)
			-- 	print("Installed Language server: " .. key)
			-- end
			-- print("Running MasonToolsInstallSync ...")
			-- vim.cmd("MasonToolsInstallSync")
			-- print("Finished installing tools.")
		end
	end,
})
