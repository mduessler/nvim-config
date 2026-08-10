local function close_stream(stream)
	if stream and not stream:is_closing() then
		stream:close()
	end
end

return close_stream
