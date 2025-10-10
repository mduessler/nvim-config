local M = {}

M.setup = function()
	local servers = require("lsp.servers")
	local signs = require("config.signs")

	vim.diagnostic.config({
		virtual_text = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = signs.diagnostics.error,
				[vim.diagnostic.severity.WARN] = signs.diagnostics.warning,
				[vim.diagnostic.severity.HINT] = signs.diagnostics.hint,
				[vim.diagnostic.severity.INFO] = signs.diagnostics.info,
			},
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = true,
			header = "",
			prefix = "",
		},
	})

	local capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		require("cmp_nvim_lsp").default_capabilities()
	)
	capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

	vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
		config = config or {}
		config.border = "rounded"
		vim.lsp.util.hover(_, result, ctx, config)
	end

	vim.lsp.handlers["textDocument/signatureHelp"] = function(_, result, ctx, config)
		config = config or {}
		config.border = "rounded"
		vim.lsp.util.signature_help(_, result, ctx, config)
	end

	local function lsp_highlight(client)
		if client.server_capabilities.documentHighlight then
			local augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
			vim.api.nvim_create_autocmd("CursorHold", {
				group = augroup,
				buffer = 0,
				callback = function()
					vim.lsp.buf.document_highlight()
				end,
			})
			vim.api.nvim_create_autocmd("CursorMoved", {
				group = augroup,
				buffer = 0,
				callback = function()
					vim.lsp.buf.clear_references()
				end,
			})
		end
	end

	local function enable_and_config_floating_window(bufnr)
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = bufnr,
			callback = function()
				local opts = {
					focusable = false,
					focus = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					border = "rounded",
					source = "always",
					prefix = " ",
					scope = "line",
				}
				vim.diagnostic.open_float(nil, opts)
			end,
		})
	end

	local function lsp_keymaps(bufnr)
		local function set(mode, keys, operation, desc)
			local status, utils = pcall(require, "utils.key")
			if not status then
				print("Can not load utils.")
				return
			end
			utils.set(mode, keys, operation, { noremap = true, silent = true, buffer = bufnr, desc = desc })
		end

		set("n", "<leader>l", "<NOP>", "LSP functions")
		set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
		set("n", "<leader>lg", vim.lsp.buf.declaration, "Go to declaration")
		set("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
		set("n", "<leader>li", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
		set("n", "<leader>lt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
		set("n", "<leader>lb", "<cmd>Teshow_line_diagnosticsscope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
		set("n", "<leader>ll", vim.diagnostic.open_float, "Show line diagnostics")
		set("n", "<leader>lp", function()
			vim.diagnostic.jump({ count = -1, border = "rounded" })
		end, "Go to previous diagnostic")
		set("n", "<leader>ln", function()
			vim.diagnostic.jump({ count = 1, border = "rounded" })
		end, "Go to next diagnostic")
		set("n", "lc", vim.lsp.buf.hover, "Show documentation for what is under cursor")
		set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "See available code actions")
		set("n", "<leader>ls", ":LspRestart<CR>", "Restart LSP")
	end

	for _, server in pairs(servers) do
		local opts = {
			on_attach = function(client, bufnr)
				if client.name == "tsserver" then
					client.server_capabilities.documentFormattingProvider = false
				end
				lsp_keymaps(bufnr)
				lsp_highlight(client)
				enable_and_config_floating_window(bufnr)
				require("lsp_signature").on_attach({
					bind = true,
					handler_opts = {
						border = "rounded",
					},
					hint_enable = true,
				}, bufnr)
			end,
			capabilities = capabilities,
		}
		local status_opts, conf_opts = pcall(require, "lsp." .. server)

		if status_opts then
			opts["settings"] = conf_opts
		end
		vim.lsp.config[server] = opts
		vim.lsp.enable(server)
	end
end

return M
