return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lua",
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
			run = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip",
		"luckasRanarison/tailwind-tools.nvim",
		"onsails/lspkind-nvim",
		"olimorris/codecompanion.nvim",
	},
	priority = 999,
	config = function()
		local require_safe = require("utils.require_safe")

		local cmp = require_safe("cmp")
		local luasnip = require_safe("luasnip")
		local signs = require_safe("config.signs")
		require("luasnip/loaders/from_vscode").lazy_load()

		if not (cmp and luasnip and signs) then
			return
		end

		local function next_item(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expandable() then
				luasnip.expand()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end

		local function prev_item(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.in_snippet() and luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end

		cmp.setup({
			enabled = function()
				local disabled = false
				disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
				disabled = disabled or (vim.fn.reg_recording() ~= "")
				disabled = disabled or (vim.fn.reg_executing() ~= "")
				disabled = vim.b[0].cmp_enabled == false
				return not disabled
			end,
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = {
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
				["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
				["<C-c>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
				["<C-y>"] = cmp.config.disable,
				["<C-e>"] = cmp.mapping({
					i = cmp.mapping.abort(),
					c = cmp.mapping.close(),
				}),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping(next_item, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(prev_item, {
					"i",
					"s",
				}),
			},
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					vim_item = require("tailwind-tools.cmp").lspkind_format(entry, vim_item)

					vim_item.kind = string.format("%s", signs.cmp[vim_item.kind])
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						nvim_lua = "[NVIM_LUA]",
						luasnip = "[Snippet]",
						buffer = "[Buffer]",
						path = "[Path]",
						codecompanion = "[AI]",
					})[entry.source.name]

					return vim_item
				end,
			},
			sources = {
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
				{ name = "codecompanion", priority = 10 },
			},
			confirm_opts = {
				behavior = cmp.ConfirmBehavior.Replace,
				select = false,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			experimental = {
				ghost_text = false,
				native_menu = false,
			},
		})
	end,
}
