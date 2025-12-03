local M = {}

M.popen = io.popen

M.get_tag = function(repo)
	local handle = M.popen("git -C " .. repo .. " describe --tags --exact-match 2>/dev/null")
	local ref = nil
	if handle then
		ref = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return ref ~= "" and ref or nil
	end
	return ref
end

M.get_branch = function(repo)
	local handle = M.popen("git -C " .. repo .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
	if handle then
		local ref = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return (ref ~= "" and ref ~= "HEAD") and ref or nil
	end
	return nil
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

M.fetch_tag = function(repo, tag)
	local handle = M.popen("git -C " .. repo .. " fetch origin tag " .. tag)
	if handle then
		local success, _, _ = handle:close()
		return success == true
	end
	return false
end

M.fetch_branch = function(repo, branch)
	local handle = M.popen("git -C " .. repo .. " fetch origin " .. branch)
	if handle then
		local success, _, _ = handle:close()
		return success == true
	end
	return false
end

M.checkout_tag = function(repo, tag)
	local handle = M.popen("git -C " .. repo .. " checkout tags/" .. tag)
	if handle then
		local success, _, _ = handle:close()
		return success == true
	end
	return false
end

M.checkout_branch = function(repo, branch)
	local handle = M.popen("git -C " .. repo .. " checkout " .. branch)
	if handle then
		local success, _, _ = handle:close()
		return success == true
	end
	return false
end

return M
