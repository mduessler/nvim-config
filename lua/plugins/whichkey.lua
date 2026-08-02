local signs = require("config.signs")

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
		{ "<leader>n", group = "Navigation", mode = "n", icon = { icon = signs.whichkey.tree, hl = "MyGreenLight" } },
		{ "<leader>ne", group = "Explorer", mode = "n", icon = LOCAL.focus },
		{ "<leader>nt", mode = "n", desc = "Toggle", icon = LOCAL.toggle },
		{ "<leader>neo", mode = "n", desc = "Open", icon = LOCAL.open },
		{ "<leader>nec", mode = "n", desc = "Close", icon = LOCAL.delete },
		{ "<leader>nef", mode = "n", desc = "Focus", icon = LOCAL.focus },
		{ "<leader>nez", mode = "n", desc = "Fold to root", icon = LOCAL.break_line },
		{ "<leader>ner", mode = "n", desc = "Refresh", icon = LOCAL.referesh },
	}
end

local function refacor_keys()
	return {
		{
			"<leader>e",
			group = "Editing",
			mode = { "n", "x" },
			icon = { icon = signs.refactor.icon, hl = "MyRed" },
		},
		{
			"<leader>em",
			mode = "x",
			desc = "Selection to method",
			icon = { icon = signs.refactor.selection_to_method, hl = "MyGreen" },
		},
		{
			"<leader>ef",
			mode = "x",
			desc = "Selection to method in new file",
			icon = { icon = signs.refactor.selection_to_file, hl = "MyYellow" },
		},
		{
			"<leader>ev",
			mode = "x",
			desc = "Create variable of selection",
			icon = { icon = signs.refactor.selection_to_variable, hl = "MyCyan" },
		},
		{
			"<leader>ei",
			mode = { "n", "x" },
			desc = "Create inline variable",
			icon = { icon = signs.refactor.inline_variable, hl = "MyRed" },
		},
		{
			"<leader>er",
			mode = { "n", "x" },
			desc = "Rename symbol",
			icon = { icon = signs.refactor.selection_to_variable, hl = "MyPurple" },
		},
		{
			"<leader>eq",
			mode = "n",
			desc = "Format current buffer",
			icon = { icon = signs.refactor.format, hl = "MyOrange" },
		},
		{
			"<leader>eI",
			mode = "n",
			desc = "Create inline method",
			icon = { icon = signs.refactor.inline_method, hl = "MyGreen" },
		},
		{
			"<leader>eb",
			mode = "n",
			desc = "Extract block",
			icon = { icon = signs.refactor.extract_block, hl = "MyGray" },
		},
		{
			"<leader>eB",
			mode = "n",
			desc = "Extract block to file",
			icon = { icon = signs.refactor.block_to_file, hl = "MyWhite" },
		},
	}
end

local function telescope_keys()
	return {
		{
			"<leader>nx",
			mode = "n",
			group = "Telescope extras",
			icon = { icon = signs.whichkey.telescope.icon, hl = "MyGreen" },
		},
		{
			"<leader>nxt",
			mode = "n",
			desc = "Open",
			icon = open,
		},
		{
			"<leader>nn",
			mode = "n",
			desc = "Open nvim config",
			icon = { icon = signs.whichkey.telescope.nvim, hl = "MyGreen" },
		},
		{
			"<leader>nb",
			mode = "n",
			desc = "Browse files",
			icon = { icon = signs.whichkey.telescope.browse, hl = "MyPurple" },
		},
		{
			"<leader>np",
			mode = "n",
			desc = "Browse projects",
			icon = { icon = signs.whichkey.telescope.projects, hl = "MyYellow" },
		},
		{
			"<leader>nf",
			mode = "n",
			desc = "Find files",
			icon = { icon = signs.whichkey.telescope.find_file, hl = "MyGreenLight" },
		},
		{
			"<leader>nxo",
			mode = "n",
			desc = "Browse oldfiles",
			icon = { icon = signs.whichkey.telescope.browse_old, hl = "MyGray" },
		},
		{
			"<leader>ng",
			mode = "n",
			desc = "Search string in cwd",
			icon = { icon = signs.whichkey.telescope.grep, hl = "MyRed" },
		},
		{
			"<leader>ns",
			mode = "n",
			desc = "Search string under cursor",
			icon = { icon = signs.whichkey.telescope.search, hl = "MyPink" },
		},
		{
			"<leader>nxd",
			mode = "n",
			desc = "Browse docker",
			icon = { icon = signs.whichkey.telescope.docker, hl = "MyBlueLight" },
		},
		{
			"<leader>nxm",
			mode = "n",
			desc = "Import modules",
			icon = { icon = signs.whichkey.telescope.find_file, hl = "MyOrange" },
		},
	}
end

local function lsp_keys()
	return {
		{ "<leader>i", mode = "n", group = "IDE", icon = LOCAL.toggle },
		{ "<leader>c", mode = { "n", "x" }, group = "Code", icon = { icon = signs.lsp.icon, hl = "MyPink" } },
		{ "<leader>cr", mode = "n", desc = "Show references", icon = { icon = signs.lsp.reference, hl = "MyBlue" } },
		{ "<leader>cg", mode = "n", desc = "Go to declaration", icon = { icon = signs.lsp._goto, hl = "MyYellow" } },
		{ "<leader>cd", mode = "n", desc = "Show definitions", icon = { icon = signs.lsp.show_def, hl = "MyOrange" } },
		{
			"<leader>ci",
			mode = "n",
			desc = "Show LSP implementations",
			icon = { icon = signs.lsp.show_def, hl = "MyPurple" },
		},
		{ "<leader>ct", mode = "n", desc = "Show type definitions", icon = { icon = signs.lsp.def, hl = "MyTeal" } },
		{
			"<leader>cb",
			mode = "n",
			desc = "Show buffer diagnostics",
			icon = { icon = signs.diagnostics.icon, hl = "MyGrey" },
		},
		{
			"<leader>cl",
			mode = "n",
			desc = "Show line diagnostics",
			icon = { icon = signs.diagnostics.icon, hl = "MyGreenLight" },
		},
		{ "<leader>cp", mode = "n", desc = "Go to previous diagnostic", icon = LOCAL.previous },
		{ "<leader>cn", mode = "n", desc = "Go to next diagnostic", icon = LOCAL.next },
		{
			"<leader>cc",
			mode = "n",
			desc = "Show documentation of word under the cursor",
			icon = { icon = "󱘞 ", color = "green" },
		},
		{
			"<leader>ca",
			mode = { "n", "v" },
			desc = "See available code actions",
			icon = { icon = signs.lsp.def, hl = "MyWhite" },
		},
		{ "<leader>is", mode = "n", desc = "Restart LSP", icon = LOCAL.referesh },
		{ "<leader>iw", mode = "n", desc = "Lint current buffer", icon = LOCAL.status },
		{ "<leader>iu", mode = "n", desc = "Toggle lsp, linter and formatter tools", icon = LOCAL.toggle },
		{ "<leader>if", mode = "n", desc = "Detect filetype and start tools", icon = LOCAL.referesh },
	}
end

local function generel_devel()
	return {
		{ "<leader>d", mode = "n", group = "Docs", icon = { icon = signs.system.file.md, hl = "MyYellow" } },
		{ "<leader>gl", mode = "n", desc = "Lazy git", icon = LOCAL.break_line },
		{ "<leader>do", mode = "n", desc = "Open markdown preview", icon = LOCAL.open },
		{ "<leader>dq", mode = "n", desc = "Close markdown preview", icon = LOCAL.quit },
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
			"<leader>dF",
			mode = "n",
			desc = "Neogen file",
			icon = { icon = signs.development.file, hl = "MyGrey" },
		},
		{
			"<leader>gg",
			mode = "n",
			desc = "Neogit",
			icon = { icon = signs.development.git, hl = "MyYellow" },
		},
		{ "<leader>tt", mode = "n", desc = "Toggle Terminal", icon = toggle },
	}
end

local function ssh_keys()
	return {
		{ "<leader>ts", mode = "n", desc = "SSH", icon = { icon = signs.whichkey.ssh.icon, hl = "MyPurple" } },
		{ "<leader>tsg", mode = "n", desc = "Start ssh", icon = LOCAL.open },
		{ "<leader>tsq", mode = "n", desc = "Quit ssh", icon = LOCAL.quit },
		{ "<leader>tsi", mode = "n", desc = "Ssh info", icon = { icon = signs.whichkey.ssh.info, hl = "MyCyan" } },
		{
			"<leader>tsc",
			mode = "n",
			desc = "Cleanup workspace and config of remote nvim",
			icon = { icon = signs.whichkey.ssh.clean_up, hl = "MyPink" },
		},
		{
			"<leader>tsd",
			mode = "n",
			desc = "Delete record or remote instance",
			icon = { icon = signs.whichkey.ssh.clean, hl = "MyOrange" },
		},
		{
			"<leader>tsl",
			mode = "n",
			desc = "Open ssh logs.",
			icon = { icon = signs.whichkey.ssh.log, hl = "MyYellow" },
		},
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
			{ "<leader>tu", mode = "n", desc = "Undotree", icon = { icon = signs.whichkey.undo, hl = "MyPurple" } },
			{ "<leader>t", mode = "n", group = "Tools", icon = LOCAL.status },
			{ "<leader>th", mode = "n", group = "HTTP", icon = LOCAL.open },
			{ "<leader>g", mode = "n", group = "Git", icon = { icon = signs.development.git, hl = "MyYellow" } },
		}, nvim_tree_keys())
		config = merge(config, refacor_keys())
		config = merge(config, telescope_keys())
		config = merge(config, lsp_keys())
		config = merge(config, generel_devel())
		config = merge(config, ssh_keys())
		wk.add(config)
	end,
}
