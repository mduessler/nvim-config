vim.api.nvim_create_autocmd("User", {
	pattern = "LazySync",
	callback = function()
		if #vim.api.nvim_list_uis() == 0 then -- headless
			print("Do nothing to install mason servers?")
			local require_safe = require("utils.require_safe")
			local servers = require_safe("lsp.servers")
			if not servers then
				return
			end
			for _, server in ipairs(servers) do
				vim.cmd("LspInstall " .. server)
				print("Installed Language server: " .. server)
			end
			vim.cmd("MasonToolsInstallSync")
			vim.cmd("TSUpdateSync")
		end
	end,
})
