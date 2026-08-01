vim.api.nvim_create_user_command("InitNVIM", function()
	if #vim.api.nvim_list_uis() == 0 then -- headless
		vim.cmd("Lazy! sync")
		vim.wait(5000)

		local formaters = require("lsp.formater")
		local linters = require("lsp.linter")
		local registry = require("mason-registry")
		local servers = require("lsp.servers")

		local function install_packages(package)
			if not registry.has_package(package) then
				print("Don't know package " .. package)
			end
			local pkg = registry.get_package(package)
			if pkg:is_installed() then
				print("Already installed: " .. package)
				return
			end
			print("Installing " .. package .. " ...")
			local done = false
			pkg:install():once("closed", function()
				done = true
			end)
			vim.wait(600000, function()
				return done
			end, 500)
			if done then
				print("Installed: " .. package)
			else
				print("Failed to install " .. package)
			end
		end

		print("Installing Language Servers.")
		for package, _ in pairs(servers) do
			install_packages(package)
		end

		print("Installing Formater")
		for package, _ in pairs(formaters) do
			if package ~= "rustfmt" then
				install_packages(package)
			end
		end

		print("Installing Linter")
		for package, _ in pairs(linters) do
			install_packages(package)
		end

		vim.wait(5000)

		print("Installing Treesitter languages.")
		require("nvim-treesitter").install({ "all" }):wait(1800000)
		vim.cmd("qa!")
	end
end, { desc = "Initalize plugins, lsps and Treesitter" })
