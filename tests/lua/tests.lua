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

require("tests.lua.utils.request_tests")

os.exit(lu.LuaUnit.run())
