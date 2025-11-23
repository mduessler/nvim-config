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

function TestRequest:test_getsuccess()
	local response = request.get(url_success)
	luaunit.assertEqual(response, { ok = true })
end

function TestRequest:test_getfailure()
	local response = request.get(url_failure)
	luaunit.assertNil(response)
	luaunit.assertErrorMsgEquals("Request to " .. url_failure .. " failed with 500")
end

function TestRequest:test_get_json_is_nil()
	local data = request.get_json(url_failure)
	luaunit.assertNil(data)
end

function TestRequest:test_get_json_decode_failure()
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

function TestRequest:test_get_json_decode_success()
	local data = request.get_json(url_success)
	luaunit.assertEqual(data, { ok = true })
end

return TestRequest
