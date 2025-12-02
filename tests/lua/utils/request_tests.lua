local lu = require("luaunit")

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
	if name == "lunajson" then
		return {
			decode = function(_)
				return { ok = true }
			end,
		}
	end
end

local request = require("lua.utils.request")

_G.TestRequest = {}

function _G.TestRequest:test_get_success()
	local response = request.get(url_success)
	lu.assertEquals(response, '{"committer":{"data":"2025-11-22t01:22:03z"}}')
end

function _G.TestRequest:test_get_failure()
	local response = request.get(url_failure)
	lu.assertNil(response)
end

function _G.TestRequest:test_get_json_is_nil()
	local data = request.get_json(url_failure)
	lu.assertNil(data)
end

function _G.TestRequest:test_get_json_decode_failure()
	package.loaded["utils.require_safe"] = function(name)
		if name == "socket.http" then
			return {
				request = function(_)
					return '{"committer":{"data":"2025-11-22t01:22:03z"}}', 200
				end,
			}
		end
		if name == "lunajson" then
			return {
				decode = function()
					return nil, 1, 2
				end,
			}
		end
	end
	package.loaded["lua.utils.request"] = nil
	local request_ = require("lua.utils.request")
	local data = request_.get_json(url_success)
	lu.assertNil(data)
end

function _G.TestRequest:test_get_json_decode_success()
	local data = request.get_json(url_success)
	lu.assertEquals(data, { ok = true })
end

return _G.TestRequest
