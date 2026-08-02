local M = {}

local delimiters = '[%s":%-]'

local function is_readable(text)
	return not text:find("[%z\1-\8\11\12\14-\31]")
end

M.parse = function(line, col)
	if line == "" or col > #line or line:sub(col, col):match(delimiters) then
		return nil
	end
	local start = col
	while start > 1 and not line:sub(start - 1, start - 1):match(delimiters) do
		start = start - 1
	end
	local stop = col
	while stop < #line and not line:sub(stop + 1, stop + 1):match(delimiters) do
		stop = stop + 1
	end
	return line:sub(start, stop), start, stop
end

M.decode = function(token)
	if #token % 4 ~= 0 or not token:match("^[A-Za-z0-9+/]+=?=?$") then
		return nil, ("'%s' is not a valid base64 string"):format(token)
	end
	local ok, decoded = pcall(vim.base64.decode, token)
	if not ok then
		return nil, ("'%s' is not a valid base64 string"):format(token)
	end
	if not is_readable(decoded) then
		return nil, "Decoded content is not a readable string"
	end
	return decoded
end

return M
