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
			for package, _ in ipairs(servers) do
				if not registry.has_package(package) then
					print("Don't know package " .. package)
				else
					local pkg = registry.get_package(package)
					if not pkg:is_installed() then
						print("[Headless] Installing " .. package .. " ...")
						pkg:install()
						vim.wait(120000, function()
							return pkg:is_installed()
						end, 500)
						print("[Headless] Installed: " .. package)
					else
						print("[Headless] Already installed: " .. package)
					end
				end
				print("Installed Language server: " .. package)
			end
			vim.cmd("MasonToolsInstallSync")
			vim.cmd("TSUpdateSync")
		end
	end,
})
