local luaunit = require("luaunit")

local TestRequest = {}

local url_success = "https://api.github.com/repos/mduessler/nvim-config/commits/SUCCESS"
local url_failure = "https://api.github.com/repos/mduessler/nvim-config/commits/FAIL"

package.loaded["utils.require_safe"] = function(name)
	if name == "socket.http" then
		return {
			request = function(url)
				if url == "https://api.github.com/repos/mduessler/nvim-config/commits/SUCCESS" then
					return '{"committer":{"data":"2025-11-22t01:22:03z"}}', 200
				else
					return '{"committer":{"data":"2025-11-22t01:22:03z"}}', 500
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

local M = require("utils.request")

TestRequest.test_get = function()
	local function test_success()
		local data = M.get(url_success)
		luaunit.assertEqual(data, { ok = true })
	end
	local function test_failure()
		local data = M.get(url_failure)
		luaunit.assertNil(data)
		luaunit.assertErrorMsgEquals("Request to " .. url_failure .. " failed with 500")
	end

	test_success()
	test_failure()
end

TestRequest.test_get_json = function() end

return TestRequest
