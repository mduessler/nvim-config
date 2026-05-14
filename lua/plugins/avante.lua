return {
	"yetone/avante.nvim",

	event = "VeryLazy",
	version = false,

	build = function()
		if vim.fn.has("win32") == 1 then
			return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		else
			return "make"
		end
	end,

	opts = {
		provider = "claude",

		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",

				-- Best current balance for coding
				model = "claude-sonnet-4-20250514",

				-- Reads automatically from your environment:
				-- export CLAUDE_API_KEY="sk-ant-..."
				api_key_name = "CLAUDE_API_KEY",

				timeout = 30000,

				extra_request_body = {
					-- Lower is better for coding
					temperature = 0.2,

					-- Prevent runaway token costs
					max_tokens = 4096,
				},
			},
		},

		-- Better UX defaults
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
