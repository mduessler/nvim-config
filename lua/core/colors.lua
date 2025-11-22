local require_safe = require("utils.require_safe")

local colors = require_safe("config.colors")

local statusline_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
local tabline_hl = vim.api.nvim_get_hl(0, { name = "TabLine" })

if not colors then
	return
end

local colors_new = {
	diagnostics = {
		error = vim.api.nvim_get_hl(0, { name = "DiagnosticError" }).fg,
		hint = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" }).fg,
		info = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" }).fg,
		warning = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" }).fg,
	},
	git = {
		changes = {
			added = "#69D603",
			deleted = "#D30D0A",
		},
		fg = "#171B24",
		modified = {
			bg = {
				_not = "#4E9A06",
				is = "#C4A000",
			},
		},
	},
	modified = {
		is_modified = "#7da232",
		is_readonly = "#3b4d18",
	},
	position = "#D0CFCF",
	quit = "#898989",
	tabline = {
		bg = {
			active = "#363D59",
			default = tabline_hl.bg,
			inactive = "#303136",
		},
		fg = {
			active = "#C1D1F6",
			default = "#D0CFCF",
			inactive = "#D0CFCF",
		},
	},
	ui = {
		diagnostics = {
			error = vim.api.nvim_get_hl(0, { name = "DiagnosticError" }).fg,
			hint = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" }).fg,
			info = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" }).fg,
			warning = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" }).fg,
		},
		fg = "#D0CFCF",
		git = {
			changes = {
				added = "#69D603",
				deleted = "#D30D0A",
			},
			fg = "#171B24",
			modified = {
				bg = {
					_not = "#4E9A06",
					is = "#C4A000",
				},
			},
		},
		modified = {
			is_modified = "#7da232",
			is_readonly = "#3b4d18",
		},
		position = "#D0CFCF",
		quit = "#898989",
		statusline = {
			battery = {
				bg = "#171B24",
				fg = {
					[0] = "#B71C1C",
					[10] = "#D32F2F",
					[20] = "#F44336",
					[30] = "#FF5722",
					[40] = "#FF9800",
					[50] = "#FFC107",
					[60] = "#FFEB3B",
					[70] = "#FFEB3B",
					[80] = "#CDDC39",
					[90] = "#8BC34A",
					[100] = "#4CAF50",
				},
			},
			bg = statusline_hl.bg,
			datetime = {
				bg = "#2D3148",
				date = "#99D65C",
				time = "#DFC653",
			},
			dirname = {
				bg = "#2D3148",
				fg = "#D0CFCF",
			},
			mode = {
				bg = {
					cmd = "#D7C4F2",
					insert = "#B3E5FC",
					normal = "#73D0FF",
					prompt = "#C3DFFF",
					replace = "#FFD6A5",
					select = "#FFCCCB",
					terminal = "#A0E7E5",
					visual = "#B2F2BB",
				},
				fg = "#171B24",
			},
			root = {
				bg = "#171B24",
				fg = "#D0CFCF",
			},
		},
		winbar = {
			active = "#00BCD4",
			bg = "#1F2430",
			file = {
				config = "#D3869B",
				git = "#FE8019",
				home = "#83A598",
				nvim = "#538F39",
				root = "#FB4934",
			},
		},
	},
}

for key, value in pairs(colors_new) do
	colors[key] = value
end

return colors
