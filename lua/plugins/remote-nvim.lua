return {
	"amitds1997/remote-nvim.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>s", "<NOP>", desc = "SSH" },
		{ "<leader>sg", "<cmd>RemoteStart<CR>", desc = "Start ssh" },
		{ "<leader>sq", "<cmd>RemoteStop<CR>", desc = "Quit ssh" },
		{ "<leader>si", "<cmd>RemoteInfo<CR>", desc = "Ssh info" },
		{ "<leader>sc", "<cmd>RemoteCleanup<CR>", desc = "Cleanup workspace and config of remote nvim" },
		{ "<leader>sd", "<cmd>RemoteConfigDel<CR>", desc = "Delete record or remote instance" },
		{ "<leader>sl", "<cmd>RemoteLog<CR>", desc = "Open ssh logs." },
	},

	config = function()
		local require_safe = require("utils.require_safe")

		local remote_nvim = require_safe("remote-nvim")
		if not remote_nvim then
			return
		end

		remote_nvim.setup({
			ssh_config = {
				ssh_config_file_paths = { "${SSH_CONFIG:-$HOME/.ssh/config}" },
			},
		})
	end,
}
