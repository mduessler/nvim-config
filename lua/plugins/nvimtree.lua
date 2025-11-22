return {
	"nvim-tree/nvim-tree.lua",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>n", "<NOP>", desc = "NvimTree" },
		{ "<leader>nt", "<cmd>NvimTreeToggle<CR>", desc = "Toggle" },
		{ "<leader>no", "<cmd>NvimTreeOpen<CR>", desc = "Open" },
		{ "<leader>nc", "<cmd>NvimTreeClose<CR>", desc = "Close" },
		{ "<leader>nf", "<cmd>NvimTreeFocus<CR>", desc = "Focus" },
		{ "<leader>nz", "<cmd>NvimTreeCollapse<CR>", desc = "Fold to root" },
		{ "<leader>nr", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh" },
	},
	config = function()
		local require_safe = require("utils.require_safe")

		local signs = require_safe("config.signs")
		local tree = require_safe("nvim-tree")

		if not (signs and tree) then
			return
		end

		tree.setup({
			disable_netrw = true,
			hijack_netrw = false,
			open_on_tab = true,
			hijack_cursor = true,
			update_cwd = true,
			hijack_directories = {
				enable = true,
				auto_open = true,
			},
			diagnostics = {
				enable = true,
				icons = {
					error = signs.diagnostics.error,
					hint = signs.diagnostics.hint,
					info = signs.diagnostics.info,
					warning = signs.diagnostics.warning,
				},
			},
			update_focused_file = {
				enable = true,
				update_cwd = true,
				ignore_list = {},
			},
			git = {
				enable = true,
				ignore = true,
				timeout = 500,
			},
			view = {
				width = 30,
				side = "left",
				number = false,
				relativenumber = false,
			},
			actions = {},
			renderer = {
				highlight_git = true,
				root_folder_modifier = ":t",
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
					glyphs = {
						default = "",
						symlink = signs.system.links.file,
						git = {
							unstaged = signs.git.unstaged,
							staged = signs.git.staged,
							unmerged = signs.git.unmerged,
							renamed = signs.git.renamed,
							deleted = signs.git.deleted,
							untracked = signs.git.untracked,
							ignored = signs.git.ignored,
						},
						folder = {
							default = signs.system.directory.default,
							open = signs.system.directory.open,
							empty = signs.system.directory.empty.default,
							empty_open = signs.system.directory.empty.open,
							symlink = signs.system.links.directory,
						},
					},
				},
			},
		})
	end,
}
