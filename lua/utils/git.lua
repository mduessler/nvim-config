local M = {}

M.popen = io.popen

--- Run a git command and return its trimmed output.
---@param repo string Path to git repository
---@param arg_string string Git subcommand and arguments (e.g., "describe --tags")
---@return string|nil trimmed command output, or nil if command failed
local function get_git_cmd_output(repo, arg_string)
	local handle = M.popen("git -C " .. repo .. " " .. arg_string)
	if handle == nil then
		return nil
	end
	local output = handle:read("*a"):gsub("%s+", "")
	local success, _, _ = handle:close()
	if success then
		return output
	end
	return nil
end

--- Get the current exact tag of the repository.
---@param repo string Path to git repository
---@return string|nil ref name if on a tag, nil otherwise
M.get_tag = function(repo)
	local ref = get_git_cmd_output(repo, "describe --tags --exact-match 2>/dev/null")
	return ref ~= "" and ref or nil
end

--- Get the current branch name.
---@param repo string Path to git repository
---@return string|nil branch name if on a branch or HEAD, otherwise nil
M.get_branch = function(repo)
	local ref = get_git_cmd_output(repo, "rev-parse --abbrev-ref HEAD 2>/dev/null")
	return (ref ~= "" and ref ~= "HEAD") and ref or nil
end

--- Determine whether the repository is on a tag or branch.
---@param repo string Path to git repository
---@return string|nil "tag" if on a tag, "branch" if on a branch, nil if neither
M.is_tag_or_branch = function(repo)
	if M.get_tag(repo) ~= nil then
		return "tag"
	elseif M.get_branch(repo) ~= nil then
		return "branch"
	else
		return nil
	end
end

--- Get the Unix timestamp of the last commit for a given revision.
---@param repo string Path to git repository
---@param revision string Commit hash (branch, tag, hash)
---@return string|nil timestamp as string, or nil on error
M.get_modified_timestamp = function(repo, revision)
	return get_git_cmd_output(repo, "log " .. revision .. " -1 --format=%cd --date=unix")
end

--- Execute a git command and return success status.
---@param repo string Path to git repository
---@param argument_string string Git subcommand and arguments
---@return boolean true on success
local function execute_simple_git_cmd(repo, argument_string)
	local handle = M.popen("git -C " .. repo .. " " .. argument_string)
	if handle then
		local success, _, _ = handle:close()
		return success == true
	end
	return false
end

--- Fetch a specific tag from origin, forcing update.
---@param repo string path to git repository
---@param tag string tag name to fetch
---@return boolean true if fetch succeeded
M.fetch_tag = function(repo, tag)
	return execute_simple_git_cmd(repo, "fetch origin tag " .. tag .. " --force")
end

--- Fetch a specific branch from origin.
---@param repo string Path to git repository
---@param branch string Branch name to fetch
---@return boolean true if fetch succeeded
M.fetch_branch = function(repo, branch)
	return execute_simple_git_cmd(repo, "fetch origin " .. branch)
end

--- Merge source branch into destination branch.
---@param repo string Path to git repository
---@param src string Source branch name
---@param dest string Destination branch name
---@return boolean true if merge succeeded
M.merge_branch = function(repo, src, dest)
	return execute_simple_git_cmd(repo, "merge " .. src .. " " .. dest)
end

return M
