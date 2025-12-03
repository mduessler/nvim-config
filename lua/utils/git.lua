local M = {}

M.popen = io.popen

local function get_git_cmd_output(repo, arg_string)
	local handle = M.popen("git -C " .. repo .. " " .. arg_string)
	if handle then
		local output = handle:read("*a"):gsub("%s+", "")
		local success, _, _ = handle:close()
		if success then
			return output
		end
	end
	return nil
end

M.get_tag = function(repo)
	local ref = get_git_cmd_output(repo, "describe --tags --exact-match 2>/dev/null")
	return ref ~= "" and ref or nil
end

M.get_branch = function(repo)
	local ref = get_git_cmd_output(repo, "rev-parse --abbrev-ref HEAD 2>/dev/null")
	return (ref ~= "" and ref ~= "HEAD") and ref or nil
end

M.is_tag_or_branch = function(repo)
	if M.get_tag(repo) ~= nil then
		return "tag"
	elseif M.get_branch(repo) ~= nil then
		return "branch"
	else
		return nil
	end
end

M.get_modified_timestamp = function(repo, revision)
	return get_git_cmd_output(repo, "log " .. revision .. " -1 --format=%cd --date=unix")
end

local function execute_simple_git_cmd(repo, argument_string)
	local handle = M.popen("git -C " .. repo .. " " .. argument_string)
	if handle then
		local success, _, _ = handle:close()
		return success == true
	end
	return false
end

M.fetch_tag = function(repo, tag)
	return execute_simple_git_cmd(repo, "fetch origin tag " .. tag .. " --force")
end

M.fetch_branch = function(repo, branch)
	return execute_simple_git_cmd(repo, "fetch origin " .. branch)
end

M.merge_branch = function(repo, src, dest)
	return execute_simple_git_cmd(repo, "merge " .. src .. " " .. dest)
end

return M
