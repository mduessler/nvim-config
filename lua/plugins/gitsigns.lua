return {
	"lewis6991/gitsigns.nvim",
	priority = 999,
	config = function()
		local require_safe = require("utils.require_safe")
		local gitsigns = require_safe("gitsigns")
		local signs = require_safe("config.signs").git
		if not (gitsigns and signs) then
			return
		end
		gitsigns.setup({
			signs = {
				add = { text = signs.add },
				change = { text = signs.change },
				delete = { text = signs.delete },
				topdelete = { text = signs.topdelete },
				changedelete = { text = signs.changedelete },
				untracked = { text = signs.untrackeq },
			},
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = {
				interval = 1000,
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil,
			max_file_length = 40000,
			preview_config = {
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
		})
	end,
}
