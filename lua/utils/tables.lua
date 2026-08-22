local function merge_array(dest, source)
	for _, value in ipairs(source) do
		table.insert(dest, value)
	end
	return dest
end

local function print_table(data, indent)
	indent = indent or 0
	local indent_string = string.rep(" ", indent)
	if type(data) == "table" then
		print("{")
		for key, value in pairs(data) do
			print(indent_string .. tostring(key) .. ":")
			print_table(value, indent + 2)
		end
		print("}")
	else
		print(indent_string .. tostring(data))
	end
end

local config = {}

config.merge_array = merge_array
config.print = print_table

return config
