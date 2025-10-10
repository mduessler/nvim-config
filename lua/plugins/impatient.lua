return {
	"lewis6991/impatient.nvim",
	config = function()
		local require_safe = require("utils.require_safe")
		local impatient = require_safe("impatient")

		if not impatient then
			return
		end

		impatient.enable_profile()
	end,
}
