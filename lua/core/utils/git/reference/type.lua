local close_process = require("core.utils.async.close_process")

--- Function to get the reference type to a commit hash. The hash has to be exist
---@param M table Module table of the git module
local function ref_type(M)
	if M._running.reference.type or M.commit.long == "" then
		return
	end

	close_process(M._handle.reference.type)
	M._running.reference.type = true

	M._handle.reference.type = vim.loop.spawn("sh", {
		args = {
			"-c",
			string.format(
				"'git tag --points-at %s | grep -q . && exit 1 || (git branch -a --points-at %s | grep -q . && exit 2 || exit 3)'",
				M.commit.long,
				M.commit.long,
				M.commit.long
			),
		},
		cwd = M.cwd,
	}, function(code, _)
		if code == 1 then
			M.reference.type = "tag"
		elseif code == 2 then
			M.reference.type = "branch"
		elseif code == 3 then
			M.reference.type = "none"
		else
			M.reference.type = nil
		end
		close_process(M._handle.reference.type)
		M._running.reference.type = false
	end)

	if not M._handle.reference.type then
		M._running.reference.type = false
		M.reference.type = nil
	end
end

return ref_type
