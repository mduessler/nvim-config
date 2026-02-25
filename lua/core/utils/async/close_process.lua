local function close_process(process)
	if process and not process:is_closing() then
		process:kill("sigterm")
		process:close()
	end
end

return close_process
