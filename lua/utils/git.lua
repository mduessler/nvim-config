local M = {}

M.get_tag = function(repo)
	local handle = io.popen("git -C " .. repo .. " describe --tags --exact-match 2>/dev/null")
	local ref = nil
	if handle then
		ref = handle:read("*a"):gsub("%s+", "")
		handle:close()
	end
	return ref
end

M.get_branch = function(repo)
	local handle = io.popen("git -C " .. repo .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
	if handle then
		local ref = handle:read("*a"):gsub("%s+", "")
		handle:close()
		if ref ~= "" and ref ~= "HEAD" then
			return ref
		end
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

return M
