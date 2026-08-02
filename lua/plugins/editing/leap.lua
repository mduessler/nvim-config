return {
	url = "https://codeberg.org/andyg/leap.nvim",
	config = function()
		vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-forward)", { desc = "Leap forward" })
		vim.keymap.set({ "n", "x", "o" }, "gS", "<Plug>(leap-backward)", { desc = "Leap backward" })
	end,
}
