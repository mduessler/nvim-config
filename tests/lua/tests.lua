local lu = require("luaunit")

vim = {
	notify = function(_, _) end,
	log = {
		levels = {
			WARN = 1,
			ERROR = 2,
		},
	},
}

require("tests.lua.utils")

os.exit(lu.LuaUnit.run())
