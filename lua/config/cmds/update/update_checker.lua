vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	desc = "Notify user about new config version.",
	once = true,
	callback = function()
		local require_safe = require("utils.require_safe")
		local git = require_safe("utils.git")
		local request = require_safe("utils.request")

		if not (git and request) then
			return
		end

		local config_directory = vim.fn.stdpath("config")
		local config_version = ""
		local last_update_timestamp = 0

		local function get_last_local_update_time(target)
			local output = git.get_modified_timestamp(config_directory, target)
			if not output then
				return nil
			end

			local local_update_time = tonumber(output)
			if not local_update_time or local_update_time % 1 ~= 0 then
				return nil
			end
			return local_update_time
		end

		local last_updated = get_last_local_update_time()
		if not last_updated then
			return
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
				return false
			end
			local handle = io.popen("git -C " .. config_directory .. " rev-parse HEAD")
			if not handle then
				return false
			end
			return commit == handle:read("*a"):gsub("%s+", "")
		end

		local target = git.is_tag_or_branch(config_directory)

		if target == "tag" then
			if not update_neded() then
				return
			end
		elseif target == "branch" then
			if config_version ~= "main" then
				return
			end
			last_update_timestamp =
				get_latest_commit_unixtime("https://api.github.com/repos/mduessler/nvim-config/branches/main")
			if last_update_timestamp <= last_updated then
				return
			end
		else
			return
		end
		vim.notify("New version is out. Compile it with", vim.log.levels.SUCCESS)
	end,
})
