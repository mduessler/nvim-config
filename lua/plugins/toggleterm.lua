return {
	"akinsho/toggleterm.nvim",
	config = function()
		local status_ok, toggleterm = pcall(require, "toggleterm")
		if not status_ok then
			return
		end
		toggleterm.setup({
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			insert_mappings = true,
			persist_size = true,
			direction = "horizontal",
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "curved",
				winblend = 0,
				highlights = {
					border = "Normal",
					background = "Normal",
				},
			},
		})
		local keymap = vim.keymap
		local opts = { noremap = true, silent = true }
		-- selene: allow(unused_variable)
		function set_terminal_keymaps()
			opts.desc = "Quit Input mode"
			keymap.set("t", "<C-esc>", [[<C-\><C-n>]], opts)
			opts.desc = "Move coursor to right window"
			keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
			opts.desc = "Move coursor to lower window"
			keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
			opts.desc = "Move coursor to upper window"
			keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
			opts.desc = "Move coursor to right window"
			keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
		end

		opts.desc = "Toggle terminal"
		keymap.set("n", "<leader>dt", ":ToggleTerm<CR>", opts)

		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

		local Terminal = require("toggleterm.terminal").Terminal

		local lazygit = Terminal:new({
			cmd = "lazygit",
			dir = "git_dir",
			direction = "float",
			float_opts = {
				border = "rounded",
			},
			-- function to run on opening the terminal
			on_open = function(term)
				vim.cmd("startinsert!")
				vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
			end,
			on_close = function()
				vim.cmd("startinsert!")
			end,
		})

		function _LAZYGIT_TOGGLE()
			lazygit:toggle()
		end
		keymap.set({ "n" }, "<leader>db", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", opts)

		local node = Terminal:new({ cmd = "node", hidden = true })

		function _NODE_TOGGLE()
			node:toggle()
		end

		local ncdu = Terminal:new({ cmd = "ncdu", hidden = true })

		function _NCDU_TOGGLE()
			ncdu:toggle()
		end

		local htop = Terminal:new({ cmd = "htop", hidden = true })

		function _HTOP_TOGGLE()
			htop:toggle()
		end

		local python = Terminal:new({ cmd = "python", hidden = true })

		function _PYTHON_TOGGLE()
			python:toggle()
		end
	end,
}
