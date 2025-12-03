local lu = require("luaunit")
local git = require("lua.utils.git")

_G.TestGit = {}

local function mock_handle(output)
	return {
		read = function()
			return output
		end,
		close = function() end,
	}
end

function _G.TestGit:test_get_tag()
	git.popen = function(_)
		return mock_handle("v1.2.3\n")
	end
	lu.assertEquals(git.get_tag("/fake/repo"), "v1.2.3")
end

function _G.TestGit:test_get_tag_nil()
	git.popen = function(_)
		return mock_handle("\n")
	end
	lu.assertNil(git.get_tag("/fake/repo"))
end

function _G.TestGit:test_get_branch()
	git.popen = function(_)
		return mock_handle("main\n")
	end
	lu.assertEquals(git.get_branch("/fake/repo"), "main")
end

function _G.TestGit:test_get_branch_nil()
	git.popen = function(_)
		return mock_handle("\n")
	end
	lu.assertNil(git.get_branch("/fake/repo"))
end

function _G.TestGit:test_get_branch_nil_for_HEAD()
	git.popen = function(_)
		return mock_handle("HEAD\n")
	end
	lu.assertNil(git.get_branch("/fake/repo"))
end

function _G.TestGit:test_is_tag_or_branch_tag()
	git.popen = function(cmd)
		if cmd:find("describe") then
			return mock_handle("v1.2.3\n")
		end
		return mock_handle("")
	end
	lu.assertEquals(git.is_tag_or_branch("/fake/repo"), "tag")
end

function _G.TestGit:test_is_tag_or_branch_branch()
	git.popen = function(cmd)
		if cmd:find("describe") then
			return mock_handle("")
		end
		return mock_handle("main\n")
	end
	lu.assertEquals(git.is_tag_or_branch("/fake/repo"), "branch")
end

function _G.TestGit:test_is_tag_or_branch_nil()
	git.popen = function(_)
		return mock_handle("")
	end
	lu.assertNil(git.is_tag_or_branch("/fake/repo"))
end

function _G.TestGit:test_fetch_tag_success()
	git.popen = function(_)
		return {
			close = function()
				return true, 0, "success"
			end,
		}
	end
	lu.assertTrue(git.fetch_tag("/fake/repo", "latest"))
end

function _G.TestGit:test_festch_tag_fail_pipe()
	git.popen = function()
		return nil
	end
	lu.assertFalse(git.fetch_tag("/fake/repo", "latest"))
end

return _G.TestGit
