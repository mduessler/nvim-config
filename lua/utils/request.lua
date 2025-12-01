local require_safe = require("utils.require_safe")
local http = require_safe("socket.http")
local cjson = require_safe("cjson")

if not (http and cjson) then
	return
end

local M = {}

M.get = function(url)
	local handle = vim.fn.system("curl", { url })
	if vim.v.shell_error ~= 0 then
		vim.notify("Request to " .. url .. " failed with " .. tostring(vim.v.shell_error) .. ".", vim.log.levels.WARN)
		return nil
	end
	if handle == nil then
		return nil
	end
	local response_body, status = http.request(url)

	if status ~= 200 then
		vim.notify("Request to " .. url .. " failed with " .. tostring(status) .. ".", vim.log.levels.WARN)
		return nil
	end
	return response_body
end

M.get_json = function(url)
	local response = M.get(url)
	if not response then
		return nil
	end

	local ok, data = pcall(cjson.decode, response)
	if not ok then
		vim.notify("Can not decode response of request to " .. url .. ".", vim.log.levels.ERROR)
		return nil
	end

	return data
end

return M
