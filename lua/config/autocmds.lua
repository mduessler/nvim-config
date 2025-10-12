vim.api.nvim_create_autocmd("User", {
	pattern = "LazySync",
	callback = function()
		if #vim.api.nvim_list_uis() == 0 then -- headless
			print("Do nothing to install mason servers?")
			local require_safe = require("utils.require_safe")
			local servers = require_safe("lua.lsp.servers")
			local registry = require_safe("mason-registry")
			if not (servers and registry) then
				return
			end
			for _, server in ipairs(servers) do
				if not registry.has_package(server) then
					print("Don't know package " .. server)
				else
					local pkg = registry.get_package(server)
					if not pkg:is_installed() then
						print("[Headless] Installing " .. server .. " ...")
						pkg:install()
						vim.wait(120000, function()
							return pkg:is_installed()
						end, 500)
						print("[Headless] Installed: " .. server)
					else
						print("[Headless] Already installed: " .. server)
					end
				end
				print("Installed Language server: " .. server)
			end
			vim.cmd("MasonToolsInstallSync")
			vim.cmd("TSUpdateSync")
		end
	end,
})
