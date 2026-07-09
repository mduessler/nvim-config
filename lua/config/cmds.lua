vim.api.nvim_create_user_command("InitNVIM", function()
	if #vim.api.nvim_list_uis() == 0 then -- headless
		vim.cmd("Lazy! sync")
		vim.wait(5000)

		local require_safe = require("utils.require_safe")
		local formaters = require_safe("lsp.formater")
		local linters = require_safe("lsp.linter")
		local registry = require_safe("mason-registry")
		local servers = require_safe("lsp.servers")

		if not (formaters and linters and registry and servers) then
			return
		end

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
		local ok, err = pcall(vim.cmd, "TSUpdateSync")
		if not ok then
			print("TSUpdateSync error: " .. tostring(err))
			vim.wait(3000)
		end
		vim.cmd("qa!")
	end
end, { desc = "Initalize plugins, lsps and Treesitter" })
