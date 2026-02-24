local require_safe = require("utils.require_safe")

local http = require_safe("socket.http")
local lunajson = require_safe("lunajson")
local logger = require_safe("utils.logger")

if not (http and lunajson and logger) then
	return
end

local M = {}

--- Function to get the given url
---@param url string The url to request
---@return string|nil body On status code 200 returns the body string, otherwise nil
M.get = function(url)
	local body, status = http.request(url)
	if type(status) ~= "number" or status ~= 200 then
		logger.WARN(string.format("Request to %s failed: %s", url, tostring(status)))
		return nil
	end
	logger.DEBUG(string.format("Success: Request to %s.", url))
	return body
end

--- Function to parse body of get request
---@param url string Url to request
---@return table|nil data On success returns the body as table, otherwise nil.
M.get_json = function(url)
	local body = M.get(url)
	if body == nil then
		return nil
	end

	local data, pos, err = lunajson.decode(body)

	if not data then
		logger.ERROR(string.format("JSON parse error for %s at position %i: %s", url, pos, err))
		return nil
	end
	return data
end

return M
