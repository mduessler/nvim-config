return {
	"mbbill/undotree",
	keys = {
		{ "<leader><F5>", vim.cmd.UndotreeToggle, desc = "Toggle UndoTree." },
		{ "j", "<Plug>UndotreePreviousState", desc = "Undo previous state.", buffer = true },
		{ "k", "<Plug>UndotreeNextState", desc = "Undo next state.", buffer = true },
	},
	config = function()
		vim.g.undotree_WindowLayout = 2
		vim.g.undotree_SetFocusWhenToggle = 1 -- Focus on the undo tree window when toggled
	end,
}
