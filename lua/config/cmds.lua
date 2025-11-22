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
end, { desc = "Initalize plugins, lsps and Treesitter" })

vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	desc = "Notify user about new config version.",
	once = true,
	callback = function()
		local config_directory = vim.fn.stdpath("config")
		local config_version = ""
		local unix_time

		function get_unix_time()
			local handle = io.popen("git -C " .. config_directory .. " log -1 --format=%cd --date=unix")
			if not handle then
				return false
			end
			unix_time = tonumber(handle:read("*a"):gsub("%s+", ""))
			if not unix_time or unix_time % 1 ~= 0 then
				error("File does not contain a valid integer: " .. tostring(unix_time))
				return false
			end
			return true
		end

		if not get_unix_time() then
			return
		end

		function is_git_tag()
			-- Checks if git HEAD is a tag.
			local handle = io.popen("git -C " .. config_directory .. " describe --tags --exact-match 2>/dev/null")
			if not handle then
				return false
			end
			config_version = handle:read("*a"):gsub("%s+", "")
			handle:close()
			return config_version ~= ""
		end

		if is_git_tag() then
			if config_version == "latest" then
				print("Check if latest is updated")
				return
			end
			print("Check if a newer tag is in the repo. And download it")
		end
	end,
})
