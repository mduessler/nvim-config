vim.api.nvim_create_user_command("InitNVIM", function()
	if #vim.api.nvim_list_uis() == 0 then -- headless
		vim.cmd("Lazy! sync")
		print("Installing Language Servers.")
		local require_safe = require("utils.require_safe")
		local servers = require_safe("lua.lsp.servers")
		local registry = require_safe("mason-registry")
		if not (servers and registry) then
			return
		end
		for package, _ in pairs(servers) do
			if not registry.has_package(package) then
				print("Don't know package " .. package)
			else
				local pkg = registry.get_package(package)
				if not pkg:is_installed() then
					print("Installing " .. package .. " ...")
					pkg:install()
					vim.wait(120000, function()
						return pkg:is_installed()
					end, 500)
					print("Installed: " .. package)
				else
					print("Already installed: " .. package)
				end
			end
			print("Installed Language server: " .. package)
		end

		print("Installing Mason tools.")
		vim.cmd("MasonToolsInstallSync")

		print("Installing Treesitter languages.")
		vim.cmd("TSUpdateSync")
	end
end, { desc = "Initalize plugins, lsps and Treesitter" })
