return {
	"windwp/nvim-autopairs",
	dependencies = {
		"hrsh7th/nvim-cmp",
		"nvim-treesitter/nvim-treesitter",
	},
	event = "InsertEnter",
	config = function()
		local require_safe = require("utils.require_safe")

		local auto_pairs = require_safe("nvim-autopairs")
		local cmp = require_safe("cmp")

		if not (auto_pairs and cmp) then
			return
		end

		auto_pairs.setup({})
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")

		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
	end,
}
