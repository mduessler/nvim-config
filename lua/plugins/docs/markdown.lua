return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function(plugin)
		if vim.fn.executable("npx") then
			vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
		else
			vim.cmd([[Lazy load markdown-preview.nvim]])
			vim.fn["mkdp#util#install"]()
		end
	end,
	init = function()
		if vim.fn.executable("npx") then
			vim.g.mkdp_filetypes = { "markdown" }
		end
	end,
	keys = {
		{ "<leader>dt", ft = "markdown", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle markdown preview" },
		{ "<leader>do", ft = "markdown", "<cmd>MarkdownPreview<cr>", desc = "Open markdown preview" },
		{ "<leader>dq", ft = "markdown", "<cmd>MarkdownPreviewStop<cr>", desc = "Close markdown preview" },
	},
	config = function()
		local function select_browser()
			local handle = io.popen("xdg-settings get default-web-browser")
			if handle == nil then
				return "firefox"
			end
			local result = handle:read("*a"):match("^%s*(.-)%s*$")
			handle:close()
			return result:gsub("%.desktop$", "")
		end

		vim.g.mkdp_browser = select_browser()
	end,
}
