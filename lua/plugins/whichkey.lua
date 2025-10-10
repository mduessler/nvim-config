local require_safe = require("utils.require_safe")

local signs = require_safe("config.signs")

if not signs then
	return
end

local LOCAL = {
	toggle = { icon = signs.whichkey.toggle, hl = "MyGrey" },
	open = { icon = signs.whichkey.open, hl = "MyGreen" },
	delete = { icon = signs.whichkey.delete, hl = "MyRed" },
	close = { icon = signs.whichkey.close, hl = "MyRed" },
	quit = { icon = signs.quit.exit, hl = "MyRed" },
	focus = { icon = signs.whichkey.focus, hl = "MyPurple" },
	referesh = { icon = signs.whichkey.refresh, hl = "MyPurple" },
	next = { icon = signs.whichkey.next, hl = "MyGreen" },
	previous = { icon = signs.whichkey.previous, hl = "MyRed" },
	help = { icon = signs.whichkey.help, hl = "MyCyan" },
	break_line = { icon = signs.whichkey.break_line, hl = "MyYellow" },
	status = { icon = signs.whichkey.status, hl = "MyOrange" },
	login = { icon = signs.whichkey.login, hl = "MyGreenLight" },
	logout = { icon = signs.whichkey.logout, hl = "MyPink" },
}

local toggle = { icon = "󰨚", color = "grey" }
local open = { icon = " ", color = "green" }

local function merge(table_1, table_2)
	for _, v in pairs(table_2) do
		table.insert(table_1, v)
	end
	return table_1
end

local function nvim_tree_keys()
	return {
		{ "<leader>n", group = "NvimTree", mode = "n", icon = { icon = signs.whichkey.tree, hl = "MyGreenLight" } },
		{ "<leader>nt", mode = "n", desc = "Toggle", icon = LOCAL.toggle },
		{ "<leader>no", mode = "n", desc = "Open", icon = LOCAL.open },
		{ "<leader>nc", mode = "n", desc = "Close", icon = LOCAL.delete },
		{ "<leader>nf", mode = "n", desc = "Focus", icon = LOCAL.focus },
		{ "<leader>nz", mode = "n", desc = "Fold to root", icon = LOCAL.break_line },
		{ "<leader>nr", mode = "n", desc = "Refresh", icon = LOCAL.referesh },
	}
end

local function refacor_keys()
	return {
		{
			"<leader>r",
			group = "Refactoring",
			mode = { "n", "x" },
			icon = { icon = signs.refactor.icon, hl = "MyRed" },
		},
		{
			"<leader>rm",
			mode = "x",
			desc = "Selection to method",
			icon = { icon = signs.refactor.selection_to_method, hl = "MyGreen" },
		},
		{
			"<leader>rf",
			mode = "x",
			desc = "Selection to method in new file",
			icon = { icon = signs.refactor.selection_to_file, hl = "MyYellow" },
		},
		{
			"<leader>rv",
			mode = "x",
			desc = "Create variable of selection",
			icon = { icon = signs.refactor.selection_to_variable, hl = "MyCyan" },
		},
		{
			"<leader>ri",
			mode = { "n", "x" },
			desc = "Create inline variable",
			icon = { icon = signs.refactor.inline_variable, hl = "MyRed" },
		},
		{
			"<leader>rn",
			mode = { "n", "x" },
			desc = "Create variable of selection",
			icon = { icon = signs.refactor.selection_to_variable, hl = "MyPurple" },
		},
		{
			"<leader>rq",
			mode = { "n", "x" },
			desc = "Format current buffer",
			icon = { icon = signs.refactor.format, hl = "MyOrange" },
		},
		{
			"<leader>rI",
			mode = "n",
			desc = "Create inline method",
			icon = { icon = signs.refactor.inline_method, hl = "MyGreen" },
		},
		{
			"<leader>rb",
			mode = "n",
			desc = "Extract block",
			icon = { icon = signs.refactor.extract_block, hl = "MyGray" },
		},
		{
			"<leader>rB",
			mode = "n",
			desc = "Extract block to file",
			icon = { icon = signs.refactor.block_to_file, hl = "MyWhite" },
		},
		{
			"<leader>rc",
			mode = "n",
			desc = "Conceal classes",
			icon = { icon = signs.refactor.conceal, hl = "MyGreenLight" },
		},
		{
			"<leader>rv",
			mode = "n",
			desc = "TailwindColorToggle",
			icon = { icon = signs.refactor.color, hl = "MyPink" },
		},
	}
end

local function telescope_keys()
	return {
		{
			"<leader>t",
			mode = "n",
			group = "whichkey.telescope",
			desc = "whichkey.telescope",
			icon = { icon = signs.whichkey.telescope.icon, hl = "MyGreen" },
		},
		{
			"<leader>tt",
			mode = "n",
			desc = "Open",
			icon = open,
		},
		{
			"<leader>tn",
			mode = "n",
			desc = "Open nvim config",
			icon = { icon = signs.whichkey.telescope.nvim, hl = "MyGreen" },
		},
		{
			"<leader>tb",
			mode = "n",
			desc = "Browse files",
			icon = { icon = signs.whichkey.telescope.browse, hl = "MyPurple" },
		},
		{
			"<leader>tp",
			mode = "n",
			desc = "Browse projects",
			icon = { icon = signs.whichkey.telescope.projects, hl = "MyYellow" },
		},
		{
			"<leader>tf",
			mode = "n",
			desc = "Find files",
			icon = { icon = signs.whichkey.telescope.find_file, hl = "MyGreenLight" },
		},
		{
			"<leader>to",
			mode = "n",
			desc = "Browse oldfiles",
			icon = { icon = signs.whichkey.telescope.browse_old, hl = "MyGray" },
		},
		{
			"<leader>tg",
			mode = "n",
			desc = "Search string in cwd",
			icon = { icon = signs.whichkey.telescope.grep, hl = "MyRed" },
		},
		{
			"<leader>ts",
			mode = "n",
			desc = "Search string under cursor",
			icon = { icon = signs.whichkey.telescope.search, hl = "MyPink" },
		},
		{
			"<leader>td",
			mode = "n",
			desc = "Browse docker",
			icon = { icon = signs.whichkey.telescope.docker, hl = "MyBlueLight" },
		},
	}
end

local function lsp_keys()
	return {
		{ "<leader>l", mode = { "n", "x" }, group = "LSP functions", icon = { icon = signs.lsp.icon, hl = "MyPink" } },
		{ "<leader>lr", mode = "n", desc = "Show references", icon = { icon = signs.lsp.reference, hl = "MyBlue" } },
		{ "<leader>lg", mode = "n", desc = "Go to declaration", icon = { icon = signs.lsp._goto, hl = "MyYellow" } },
		{ "<leader>ld", mode = "n", desc = "Show definitions", icon = { icon = signs.lsp.show_def, hl = "MyOrange" } },
		{ "<leader>lu", mode = "n", desc = "Show usage", icon = { icon = signs.lsp.show_def, hl = "MyPurple" } },
		{ "<leader>lt", mode = "n", desc = "Show type definitions", icon = { icon = signs.lsp.def, hl = "MyTeal" } },
		{
			"<leader>lb",
			mode = "n",
			desc = "Show buffer diagnostics",
			icon = { icon = signs.diagnostics.icon, hl = "MyGrey" },
		},
		{
			"<leader>ll",
			mode = "n",
			desc = "Show line diagnostics",
			icon = { icon = signs.diagnostics.icon, hl = "MyGreenLight" },
		},
		{ "<leader>lp", mode = "n", desc = "Go to previous diagnostics", icon = LOCAL.previous },
		{ "<leader>ln", mode = "n", desc = "Go to next diagnostics", icon = LOCAL.next },
		{
			"<leader>lC",
			mode = "n",
			desc = "Show documentation of word under the cursor",
			icon = { icon = "󱘞 ", color = "green" },
		},
		{
			"<leader>la",
			mode = "n",
			desc = "See available code actions",
			icon = { icon = signs.lsp.def, hl = "MyWhite" },
		},
	}
end

local function generel_devel()
	return {
		{ "<leader>d", mode = "n", desc = "General devel", icon = { icon = signs.system.file.md, hl = "MyYellow" } },
		{ "<leader>db", mode = "n", desc = "Lazy git", icon = LOCAL.break_line },
		{ "<leader>do", mode = "n", desc = "Open MarkdownPreview", icon = LOCAL.open },
		{ "<leader>dq", mode = "n", desc = "Close MarkdownPreview", icon = LOCAL.quit },
		{ "<leader>dm", mode = "n", desc = "Toggle MarkdownPreview", icon = LOCAL.toggle },
		{
			"<leader>df",
			mode = "n",
			desc = "Neogen function",
			icon = { icon = signs.development._function, hl = "MyPurple" },
		},
		{
			"<leader>dc",
			mode = "n",
			desc = "Neogen class",
			icon = { icon = signs.development.class, hl = "MyOrange" },
		},
		{
			"<leader>dp",
			mode = "n",
			desc = "Neogen type",
			icon = { icon = signs.development.type_parameter, hl = "MyCyan" },
		},
		{
			"<leader>df",
			mode = "n",
			desc = "Neogen file",
			icon = { icon = signs.development.file, hl = "MyGrey" },
		},
		{
			"<leader>dg",
			mode = "n",
			desc = "Neogit",
			icon = { icon = signs.development.git, hl = "MyYellow" },
		},
		{ "<leader>dt", mode = "n", desc = "Toggle Terminal", icon = toggle },
	}
end

local function ai_keys()
	return {
		{ "<leader>c", mode = "n", desc = "Copilot", icon = { icon = signs.whichkey.copilot, hl = "MyOrange" } },
		{ "<leader>ce", mode = "n", desc = "Enable Copilot", icon = LOCAL.login },
		{ "<leader>cd", mode = "n", desc = "Disable Copilot", icon = LOCAL.logout },
		{
			"<leader>ca",
			mode = "n",
			desc = "Authenticate Copilot",
			icon = { icon = signs.whichkey.copilot, hl = "MyCyan" },
		},
		{ "<leader>cm", mode = "n", desc = "Status Copilot", icon = LOCAL.status },
		{ "<leader>ch", mode = "n", desc = "Copilot Help", icon = LOCAL.help },
		{
			"<leader>cp",
			mode = "n",
			desc = "Suggest output with Copilot",
			icon = { icon = signs.whichkey.list, hl = "MyOrange" },
		},
		{ "<leader>co", mode = "n", desc = "Open copilot chat window", icon = LOCAL.open },
		{ "<leader>cq", mode = "n", desc = "Close copilot chat window", icon = LOCAL.quit },
		{ "<leader>ct", mode = "n", desc = "Toggle copilot chat window", icon = LOCAL.toggle },
		{ "<leader>cs", mode = "n", desc = "Stops copilot chat window", icon = LOCAL.close },
		{ "<leader>cr", mode = "n", desc = "Restart copilot chat window", icon = LOCAL.referesh },
	}
end

return {
	"folke/which-key.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function()
		local wk = require("which-key")
		wk.setup({
			preset = "modern",
			icons = {
				separator = "•",
				group = "",
			},
			keys = {
				scroll_down = "<c-d>", -- binding to scroll down inside the popup
				scroll_up = "<c-u>", -- binding to scroll up inside the popup
			},
		})
		local config = merge({
			{ "<leader><F5>", mode = "n", desc = "Undotree", icon = { icon = signs.whichkey.undo, hl = "MyPurple" } },
		}, nvim_tree_keys())
		config = merge(config, refacor_keys())
		config = merge(config, telescope_keys())
		config = merge(config, lsp_keys())
		config = merge(config, generel_devel())
		config = merge(config, ai_keys())
		wk.add(config)
	end,
}
