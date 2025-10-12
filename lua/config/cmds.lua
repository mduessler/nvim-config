vim.api.nvim_create_user_command("InitNVIM", function()
	if #vim.api.nvim_list_uis() == 0 then -- headless
		local require_safe = require("utils.require_safe")

		local lazy = require_safe("lazy")
		if not lazy then
			print("Lazy not loaded!")
		end

		lazy.sync({ wait = true })
		vim.wait(60000, function()
			local cfg = require("lazy.core.config")
			return cfg and cfg.plugins and next(cfg.plugins) ~= nil
		end, 500)

		local formaters = require_safe("lua.lsp.formater")
		local linters = require_safe("lua.lsp.linter")
		local mti = require_safe("mason-tool-installer")
		local registry = require_safe("mason-registry")
		local servers = require_safe("lua.lsp.servers")

		if not (formaters and linters and mti and registry and servers) then
			return
		end

		local function install_packages(package)
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

		print("Installing Language Servers.")
		for package, _ in pairs(servers) do
			install_packages(package)
		end

		print("Installing Formater")
		for package, _ in pairs(formaters) do
			install_packages(package)
		end

		print("Installing Linter")
		for package, _ in pairs(linters) do
			install_packages(package)
		end

		print("Installing Treesitter languages.")
		vim.cmd("TSUpdate")

		vim.wait(5000)
	end
end, { desc = "Initalize plugins, lsps and Treesitter" })
