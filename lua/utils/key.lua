local utils = {}

utils.set = function(mode, keys, operation, opts)
	if not opts then
		opts = { silent = true }
	end
	vim.keymap.set(mode, keys, operation, opts)
end

utils.del = function(mode, key)
	vim.keymap.del(mode, key)
end

return utils
