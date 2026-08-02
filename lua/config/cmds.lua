vim.api.nvim_create_user_command("InitNVIM", function()
	if #vim.api.nvim_list_uis() ~= 0 then
		return
	end

	-- Write progress unbuffered so e.g. `docker build` shows it live.
	local function log(msg)
		io.write(msg .. "\n")
		io.flush()
	end

	vim.cmd("Lazy! sync")
	vim.wait(5000)

	local formaters = require("lsp.formater")
	local linters = require("lsp.linter")
	local registry = require("mason-registry")
	local servers = require("lsp.servers")

	local failures = 0

	log("Refreshing mason registry ...")
	registry.refresh()

	local function install_package(package)
		if not registry.has_package(package) then
			log("Don't know package " .. package)
			failures = failures + 1
			return
		end
		local pkg = registry.get_package(package)
		if pkg:is_installed() then
			log("Already installed: " .. package)
			return
		end
		log("Installing " .. package .. " ...")
		local done = false
		pkg:install():once("closed", function()
			done = true
		end)
		vim.wait(600000, function()
			return done
		end, 500)
		-- "closed" also fires for failed installations, so verify the result.
		if done and pkg:is_installed() then
			log("Installed: " .. package)
		else
			log("Failed to install " .. package)
			failures = failures + 1
		end
	end

	log("Installing Language Servers.")
	for package, _ in pairs(servers) do
		install_package(package)
	end

	log("Installing Formater")
	for package, _ in pairs(formaters) do
		if package ~= "rustfmt" then
			install_package(package)
		end
	end

	log("Installing Linter")
	for package, _ in pairs(linters) do
		install_package(package)
	end

	vim.wait(5000)

	log("Installing Treesitter languages.")
	require("nvim-treesitter").install({ "all" }):wait(1800000)

	if failures > 0 then
		log("InitNVIM finished with " .. failures .. " failed package installation(s).")
		vim.cmd("cquit! 1")
	end

	log("InitNVIM finished successfully.")
	vim.cmd("qa!")
end, { desc = "Initalize plugins, lsps and Treesitter" })
