local mdformat_pip = vim.fn.stdpath("data") .. "/mason/packages/mdformat/venv/bin/pip"

local M = {}

local function install_gfm()
	vim.system({ mdformat_pip, "install", "mdformat-gfm" }, {}, function(res)
		vim.schedule(function()
			if res.code == 0 then
				vim.notify("Installed mdformat-gfm", vim.log.levels.INFO)
			else
				vim.notify("Installation of mdformat-gfm failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
			end
		end)
	end)
end

M.install_plugins = function()
	install_gfm()
end

return M
