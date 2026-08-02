local M = {}

M.setup = function()
	vim.api.nvim_create_user_command("DecodeBase64", require("core.code.base64").decode, {
		desc = "Decode the base64 string under the cursor into readable text",
	})
end

return M
