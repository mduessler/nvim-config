return {
	"amitds1997/remote-nvim.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local require_safe = require("utils.require_safe")

		local remote_nvim = require_safe("remote-nvim")
		if not remote_nvim then
			return
		end
		remote_nvim.setup({
			ssh_config_file_paths = { "${SSH_CONFIG:-$HOME/.ssh/config}" },
		})
	end,
}
