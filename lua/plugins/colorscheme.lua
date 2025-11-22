return {
	"Shatur/neovim-ayu",
	priority = 1000,
	opts = {
		mirage = true,
		overrides = {},
	},
	config = function()
		local status, ayu = pcall(require, "ayu")
		if not status then
			return
		end
		ayu.setup({
			mirage = true,
			overrides = {
				normal = {
					bg = "#17202A",
				},
			},
			options = { theme = "ayu" },
		})
		ayu.colorscheme()
	end,
}
