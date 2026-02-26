local require_safe = require("utils.require_safe")
local close_process = require_safe("core.utils.async.close_process")

if not close_process then
	return
end

--- Function to get the reference type to a commit hash. The hash has to be exist
---@param M table Module table of the git module
local function ref_type(M)
	if M.running.reference.type or M.commit == nil then
		return
	end

	close_process(M.handle.reference.type)
	M.running.reference.type = true

	M.handle.reference.type = vim.loop.spawn("sh", {
		args = {
			"-c",
			string.format(
				"'cd %s && git tag --points-at %s | grep -q . && exit 1 || (git branch -a --points-at %s | grep -q . && exit 2 || exit 3)'",
				vim.fn.stdpath("config"),
				M.commit,
				M.commit,
				M.commit
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
		close_process(M.handle.reference.type)
		M.running.reference.type = false
	end)

	if not M.handle.reference.type then
		M.running.reference.type = false
		M.reference.type = nil
	end
end

return ref_type
