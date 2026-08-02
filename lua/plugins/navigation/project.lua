return {
	"ahmedkhalf/project.nvim",
	config = function()
		require("project_nvim").setup({
			active = true,
			on_config_done = nil,
			manual_mode = false,
			detection_methods = { "pattern" },
			patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
			show_hidden = true,
			silent_chdir = true,
			ignore_lsp = {},
			datapath = vim.fn.stdpath("data"),
		})
	end,
}
