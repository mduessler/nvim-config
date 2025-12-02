require("config.options")
require("config.lazy")
require("config.highlights")
require("config.keymaps")

if #vim.api.nvim_list_uis() == 0 then
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

	vim.wait(5000)

	print("Installing Treesitter languages.")
	vim.cmd("TSUpdateSync")
	vim.cmd("qa!")
end
