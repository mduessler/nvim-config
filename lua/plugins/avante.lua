return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	build = "make",
	opts = {
		provider = "claude",
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-4-6",
				api_key_name = "CLAUDE_API_KEY", -- Reads automatically from your environment
				timeout = 30000,
				extra_request_body = {
					temperature = 0.2,
					max_tokens = 4096,
				},
			},
		},
		behaviour = {
			auto_suggestions = false,
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = true,
		},
		highlights = {
			diff = {
				current = "DiffText",
				incoming = "DiffAdd",
			},
		},

		windows = {
			position = "right",
			wrap = true,
			width = 35,
			sidebar_header = {
				enabled = true,
				align = "center",
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown", "Avante" },
			opts = {
				file_types = { "markdown", "Avante" },
			},
		},
	},
}
