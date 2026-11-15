local registry = require("mason-registry")

local md_format = require("lsp.mason_extras.md_format")

registry:on("package:install:success", function(pkg)
	if pkg.name == "mdformat" then
		vim.schedule(md_format.install_plugins)
	end
end)

if registry.is_installed("mdformat") then
	md_format.check_plugins()
end
