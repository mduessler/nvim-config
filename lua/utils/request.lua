local require_safe = require("utils.require_safe")
local http = require_safe("socket.http")
local lunajson = require_safe("lunajson")

if not (http and lunajson) then
	return
end

local M = {}

M.get = function(url)
	local response = http.request(url)

	if response.status ~= 200 then
		vim.notify("Request to " .. url .. " failed with " .. tostring(response.status) .. ".", vim.log.levels.WARN)
		return nil
	end
	return response
end

M.get_json = function(url)
	local resp_body, _ = M.get(url)
	if not resp_body then
		return nil
	end

	local data, pos, err = lunajson.decode(resp_body)

	if not data then
		vim.notify(
			"Can not decode response of request to " .. url .. ".\nJSON parse error at position " .. pos .. ":" .. err,
			vim.log.levels.ERROR
		)
	end
	return data
end

return M
