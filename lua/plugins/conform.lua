return {
	"stevearc/conform.nvim",
	dependencies = "luckasRanarison/tailwind-tools.nvim",
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	keys = {
		{
			"<leader>rq",
			function()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 500,
				})
			end,
			noremap = true,
			silent = true,
			desc = "Format current buffer",
		},
	},
	config = function()
		local require_safe = require("utils.require_safe")
		local conform = require_safe("conform")

		if not conform then
			return
		end

		conform.setup({
			formatters_by_ft = {
				sh = { "shfmt" },
				zsh = { "beautysh" },
				c = { "clang-format" },
				cmake = { "cmake_format" },
				cpp = { "clang_format" },
				css = { "prettier" },
				html = { "djlint" },
				htmldjango = { "djlint" },
				java = { "google-java-format" },
				javascript = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
				markdown = { "mdformat" },
				rust = { "rustfmt" },
				python = { "isort", "black" },
				typescript = { "prettier" },
				yaml = { "yamlfmt" },
				xml = { "xmlformatter" },
			},
			formatters = {
				black = {
					prepend_args = function()
						return { "--line-length", "99" }
					end,
				},
				cargo_fmt = {
					command = "cargo",
					args = { "fmt", "--all" },
					stdin = false,
				},
				clang_format = {
					prepend_args = function()
						return { "--style=file" }
					end,
				},
				isort = {
					prepend_args = function()
						return { "--profile", "black", "--line-length", "99" }
					end,
				},
				mdformat = {
					prepend_args = function()
						return { "--number" }
					end,
				},
				shfmt = {
					prepend_args = function()
						return { "-i", "2", "-bn", "-ci" }
					end,
				},
				stylua = {
					options = {
						config_path = "$HOME/.config/stylua.toml",
					},
				},
			},
			format_on_save = false,
		})
	end,
}
