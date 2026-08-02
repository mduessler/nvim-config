local M = {}

M.setup = function()
	local base64 = require("core.code.base64")

	vim.api.nvim_create_user_command("ToggleBase64", base64.toggle, {
		desc = "Toggle the decoded view of the base64 string under the cursor",
	})
	vim.api.nvim_create_user_command("ResetBase64", base64.reset, {
		desc = "Show all base64 strings in their original encoding again",
	})
end

return M
