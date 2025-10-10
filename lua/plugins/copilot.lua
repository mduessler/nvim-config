return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{
			"github/copilot.vim",
			lazy = true,
			cmd = "Copilot",
			keys = {
				{ "<leader>c", "<NOP>", desc = "Enable Copilot" },
				{ "<leader>ce", "<cmd>Copilot enable<CR><cmd>Copilot status<CR>", desc = "Enable Copilot" },
				{ "<leader>cd", "<cmd>Copilot disable<CR><cmd>Copilot status<CR>", desc = "Disable Copilot" },
				{ "<leader>ca", "<cmd>Copilot auth<CR>", desc = "Authenticate Copilot" },
				{ "<leader>cm", "<cmd>Copilot status<CR>", desc = "Status Copilot" },
				{ "<leader>cp", "<cmd>Copilot panel<CR>", desc = "Suggest output with Copilot" },
				{ "<leader>ch", "<cmd>Copilot help<CR>", desc = "Copilot help" },
			},
			config = function()
				vim.g.copilot_enabled = false
				vim.g.copilot_no_tab_map = true
				vim.g.copilot_assume_mapped = true
			end,
		},
		{
			"nvim-lua/plenary.nvim",
			branch = "master",
		},
	},
	keys = {
		{ "<leader>co", "<cmd>CopilotChatOpen<CR>", desc = "Open copilot chat window" },
		{ "<leader>cq", "<cmd>CopilotChatClose<CR>", desc = "Close copilot chat window" },
		{ "<leader>ct", "<cmd>CopilotChatToggle<CR>", desc = "Toggle copilot chat window" },
		{ "<leader>cs", "<cmd>CopilotChatStop<CR>", desc = "Stops copilot chat window" },
		{ "<leader>cr", "<cmd>CopilotChatRestart<CR>", desc = "Restart copilot chat window" },
	},
	build = "make tiktoken",
	opts = {},
}
