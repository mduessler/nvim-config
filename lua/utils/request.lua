local require_safe = require("utils.require_safe")
local http = require_safe("socket.http")
local cjson = require_safe("cjson")

if not (http and cjson) then
	return
end

local M = {}

local function get(url)
	local response_body, status = http.request(url)

	if status ~= 200 then
		error("Request to " .. url .. " failed with " .. tostring(status))
		return nil
	end
	return response_body
end

M.get_json = function(url)
	local response = get(url)
	if not response then
		return nil
	end

	local ok, data = pcall(cjson.decode, response)
	if not ok then
		return nil
	end

	return data
end

return M
