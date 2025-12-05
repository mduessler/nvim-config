vim.api.nvim_create_user_command("UpdateNVIMConfig", function()
	local require_safe = require("utils.require_safe")

	local git = require_safe("utils.git")
	local request = require_safe("utils.request")

	if not (git and request) then
		return
	end

	local config_dir = vim.fn.stdpath("config")

	local target = git.is_tag_or_branch(config_dir)
	if target == "tag" then
		if git.fetch_tag(config_dir, "latest") then
			return
		end
		vim.notify("Can not fetch tag latest", vim.log.levels.ERROR)
	elseif target == "branch" then
		if git.fetch_branch(config_dir, "main") then
			return git.merge_branch(config_dir, "origin/main", "main")
		end
		vim.notify("Can not fetch main branch", vim.log.levels.ERROR)
	end
	vim.notify("Can not update. Skipping.", vim.log.levels.WARN)
end, { desc = "Update the NVIM config." })
