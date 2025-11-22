return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-file-browser.nvim",
		"nvim-telescope/telescope-project.nvim",
		"ThePrimeagen/harpoon",
		"nvim-telescope/telescope-media-files.nvim",
		"nvim-tree/nvim-web-devicons",
		"ahmedkhalf/project.nvim",
		"lpoto/telescope-docker.nvim",
		{
			"piersolenski/telescope-import.nvim",
			dependencies = "nvim-telescope/telescope.nvim",
			config = function()
				require("telescope").load_extension("import")
			end,
		},
	},
	event = "VimEnter",
	priority = 999,
	keys = {
		{
			"<leader>t",
			"<NOP>",
			noremap = true,
			silent = true,
			desc = "Telescope",
		},
		{
			"<leader>tt",
			"<cmd>Telescope<CR>",
			noremap = true,
			silent = true,
			desc = "Open",
		},
		{
			"<leader>tn",
			"<cmd>Telescope file_browser path=$HOME/.config/nvim select_buffer=true<CR><CR>",
			noremap = true,
			silent = true,
			desc = "Open nvim config",
		},
		{
			"<leader>tb",
			"<cmd>Telescope file_browser<CR>",
			noremap = true,
			silent = true,
			desc = "Browse files",
		},
		{
			"<leader>tp",
			"<cmd>Telescope projects<CR>",
			noremap = true,
			silent = true,
			desc = "Browse projects",
		},
		{
			"<leader>tf",
			"<cmd>Telescope find_files<CR>",
			noremap = true,
			silent = true,
			desc = "Find files",
		},
		{
			"<leader>to",
			"<cmd>Telescope oldfiles<CR>",
			noremap = true,
			silent = true,
			desc = "Browse oldfiles",
		},
		{
			"<leader>tg",
			"<cmd>Telescope live_grep<CR>",
			noremap = true,
			silent = true,
			desc = "Search string in cwd",
		},
		{
			"<leader>ts",
			"<cmd>Telescope grep_string<CR>",
			noremap = true,
			silent = true,
			desc = "Search string under cursor",
		},
		{
			"<leader>td",
			"<cmd>Telescope docker<CR>",
			noremap = true,
			silent = true,
			desc = "Browse docker",
		},
		{
			"<leader>tm",
			"<cmd>Telescope import<CR>",
			noremap = true,
			silent = true,
			desc = "Import modules",
		},
	},
	opts = function()
		local actions = require("telescope.actions")
		local signs = require("config.signs")
		local general_mappings = {
			["<C-c>"] = actions.close,

			["<C-n>"] = actions.cycle_history_next,
			["<C-p>"] = actions.cycle_history_prev,

			["<C-j>"] = actions.move_selection_next,
			["<C-k>"] = actions.move_selection_previous,

			["<C-l>"] = actions.select_default,
			["<C-b>"] = actions.select_horizontal,
			["<C-v>"] = actions.select_vertical,
			["<C-t>"] = actions.select_tab,

			["<C-u>"] = actions.preview_scrolling_up,
			["<C-d>"] = actions.preview_scrolling_down,

			["<PageUp>"] = actions.results_scrolling_up,
			["<PageDown>"] = actions.results_scrolling_down,

			["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
			["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
			["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
			["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
			["<CR>"] = actions.select_default,
			["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
		}
		local config = {
			defaults = {
				theme = "center",
				sorting_strategy = "ascending",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.5,
					},
				},
				prompt_prefix = signs.telescope.prompt .. " ",
				selection_caret = signs.telescope.selection .. " ",
				path_display = { "smart" },
				mappings = {
					i = general_mappings,
					n = general_mappings,
				},
			},
			pickers = {
				search_string = "builtin.live_grep",
			},
			extensions = {
				file_browser = {
					hijack_netrw = true,
					use_fd = true,
					prompt_path = true,
					hidden = true,
					mappings = {
						["i"] = {},
						["n"] = {},
					},
				},
				project = {
					base_dirs = {},
					hidden_files = false, -- default: false
					theme = "dropdown",
					order_by = "desc",
					search_by = "title",
				},
				import = {
					insert_at_top = true,
					custom_languages = {
						{
							extensions = { "js", "ts" },
							filetypes = { "vue" },
							insert_at_line = 2,
							regex = [[^(?:import(?:[\"'\s]*([\w*{}\n, ]+)from\s*)?[\"'\s](.*?)[\"'\s].*)]],
						},
					},
				},

				media_files = {
					filetypes = { "png", "webp", "jpg", "jpeg", "pdf", "mp4", "webm" },
					find_cmd = "rg",
				},
				theme = "ivy",
				binary = "docker", -- in case you want to use podman or something
				compose_binary = "docker compose",
				buildx_binary = "docker buildx",
				machine_binary = "docker --version",
				log_level = vim.log.levels.INFO,
			},
		}
		return config
	end,
	config = function()
		local telescope = require("telescope")
		telescope.load_extension("fzf")
		local file_browser = require("telescope").load_extension("file_browser")
		require("telescope.builtin").file_browser = file_browser.file_browser
		telescope.load_extension("project")
		telescope.load_extension("projects")
		telescope.load_extension("media_files")
		telescope.load_extension("docker")
	end,
}
