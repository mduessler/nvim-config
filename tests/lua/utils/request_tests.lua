local luaunit = require("luaunit")

local TestRequest = {}

local M = require("utils.request")

TestRequest.test_get = function()
	package.loaded["utils.require_safe"] = function(name)
		if name == "socket.http" then
			return {
				request = function(url)
					if url == "https://api.github.com/repos/mduessler/nvim-config/commits/SUCCESS" then
						return '{"committer":{"data":"2025-11-22T01:22:03Z"}}', 200
					else
						return '{"committer":{"data":"2025-11-22T01:22:03Z"}}', 500
					end
				end,
			}
		end
		if name == "cjson" then
			return {
				decode = function(_)
					return { ok = true }
				end,
			}
		end
	end
	local function test_success()
		local data = M.get("https://api.github.com/repos/mduessler/nvim-config/commits/SUCCESS")
		luaunit.assertEqual(data, { ok = true })
	end
	local function test_failure()
		local url = "https://api.github.com/repos/mduessler/nvim-config/commits/FAIL"
		local data = M.get(url)
		luaunit.assertNil(data)
		luaunit.assertErrorMsgEquals("Request to " .. url .. " failed with 500")
	end

	test_success()
	test_failure()
end

return TestRequest
