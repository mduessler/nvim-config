local luaunit = require("luaunit")

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

local request = require("utils.request")

local TestRequest = {}

TestRequest.test_get = function()
	local function test_success()
		local data = request.get(url_success)
		luaunit.assertEqual(data, { ok = true })
	end
	local function test_failure()
		local data = request.get(url_failure)
		luaunit.assertNil(data)
		luaunit.assertErrorMsgEquals("Request to " .. url_failure .. " failed with 500")
	end

	test_success()
	test_failure()
end

TestRequest.test_get_json = function()
	local function test_response_is_nil()
		local data = request.get_json(url_failure)
		luaunit.assertNil(data)
	end
	local function test_decode_failure()
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
					decode = function()
						error("bad json")
					end,
				}
			end
		end
		local request_ = require("utils.request")
		local data = request_.get_json(url_success)
		luaunit.assertNil(data)
		luaunit.assertErrorMsgEquals("Can not decode response of request to " .. url_success .. ".")
	end
	local function test_decode_success()
		local data = request.get_json(url_success)
		luaunit.assertEqual(data, { ok = true })
	end
	test_response_is_nil()
	test_decode_failure()
	test_decode_success()
end

return TestRequest
