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
		local require_safe = require("utils.require_safe")
		local request = require_safe("utils.request")

		if not request then
			return
		end

		local config_directory = vim.fn.stdpath("config")
		local config_version = ""
		local last_update_timestamp = 0

		local function get_last_local_update_time()
			local handle = io.popen("git -C " .. config_directory .. " log -1 --format=%cd --date=unix")
			if not handle then
				return nil
			end
			local output = handle:read("*a")
			handle:close()
			if not output then
				return nil
			end
			output = output:gsub("%s+", "")
			local local_update_time = tonumber(output)
			if not local_update_time or local_update_time % 1 ~= 0 then
				return nil, "Git output is not a valid integer: " .. tostring(output)
			end
			return local_update_time
		end

		local last_updated = get_last_local_update_time()
		if not last_updated then
			return
		end

		local function is_git_tag()
			-- Checks if git HEAD is a tag.
			local handle = io.popen("git -C " .. config_directory .. " describe --tags --exact-match 2>/dev/null")
			if not handle then
				return false
			end
			config_version = handle:read("*a"):gsub("%s+", "")
			handle:close()
			return config_version ~= ""
		end

		local function get_latest_commit_unixtime(url)
			local response = request.get_json(url)
			local date = response.commit.committer.date
			local year, month, day, hour, min, sec = date:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
			return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec, isdst = false })
		end

		local function update_neded()
			local response = request.get_json("https://api.github.com/repos/mduessler/nvim-config/tags")
			local commit = nil
			for _, tag in ipairs(response) do
				if tag.name == "latest" then
					commit = tag.commit.sha
				end
			end
			if not commit then
				error("Could not get sha of latest.")
			end
			local handle = io.popen("git -C " .. config_directory .. " rev-parse HEAD")
			if not handle then
				return
			end
			return commit == handle:read("*a"):gsub("%s+", "")
		end

		if is_git_tag() then
			if update_neded() then
				print("Update tag to latest.")
			end
			return
		else
			if config_version ~= "main" then
				print("Skip this, only update main.")
				return
			end
			last_update_timestamp =
				get_latest_commit_unixtime("https://api.github.com/repos/mduessler/nvim-config/branches/main")
			if last_update_timestamp > last_updated then
				print("UPDATE!")
			end
		end
	end,
})
