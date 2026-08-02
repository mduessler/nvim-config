return {
	"jghauser/follow-md-links.nvim",
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown" },
			callback = function()
				vim.keymap.set("n", "<bs>", ":edit #<cr>", { silent = true })
			end,
		})
	end,
}
