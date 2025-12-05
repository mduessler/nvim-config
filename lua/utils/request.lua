local http = require("socket.http")
local lunajson = require("lunajson")

if not (http and lunajson) then
	return
end

local M = {}

M.get = function(url)
	local body, status = http.request(url)

	if status ~= 200 then
		if vim then
			vim.notify("Request to " .. url .. " failed with " .. tostring(status) .. ".", vim.log.levels.WARN)
		end
		return nil
	end
	return body
end

M.get_json = function(url)
	local body = M.get(url)
	if not body then
		return nil
	end

	local data, pos, err = lunajson.decode(body)

	if not data then
		if vim then
			vim.notify(
				"Can not decode response of request to "
					.. url
					.. ".\nJSON parse error at position "
					.. pos
					.. ":"
					.. err,
				vim.log.levels.ERROR
			)
		end
	end
	return data
end

return M
