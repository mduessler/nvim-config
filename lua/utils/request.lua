local require_safe = require("utils.require_safe")
local http = require_safe("socket.http")
local json = require_safe("json")

if not (http and json) then
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

M.requst_json = function(url)
	local response = get(url)
	if not response then
		return {}
	end
	return json.decode(response)
end

return M
