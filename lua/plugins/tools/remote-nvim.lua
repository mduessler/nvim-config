return {
	"amitds1997/remote-nvim.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>ts", "<NOP>", desc = "SSH" },
		{ "<leader>tsg", "<cmd>RemoteStart<CR>", desc = "Start ssh" },
		{ "<leader>tsq", "<cmd>RemoteStop<CR>", desc = "Quit ssh" },
		{ "<leader>tsi", "<cmd>RemoteInfo<CR>", desc = "Ssh info" },
		{ "<leader>tsc", "<cmd>RemoteCleanup<CR>", desc = "Cleanup workspace and config of remote nvim" },
		{ "<leader>tsd", "<cmd>RemoteConfigDel<CR>", desc = "Delete record or remote instance" },
		{ "<leader>tsl", "<cmd>RemoteLog<CR>", desc = "Open ssh logs." },
	},

	config = function()
		local remote_nvim = require("remote-nvim")

		remote_nvim.setup({
			ssh_config = {
				ssh_config_file_paths = { "${SSH_CONFIG:-$HOME/.ssh/config}" },
			},
		})
	end,
}
