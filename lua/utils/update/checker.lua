local git = require("lua.utils.git")
local request = require("lua.utils.request")

if not (git and request) then
	os.exit(2)
end

local config_dir = arg[1]
local main_branch_url = "https://api.github.com/repos/mduessler/nvim-config/branches/main"
local tags_url = "https://api.github.com/repos/mduessler/nvim-config/tags"

local function get_local_timestamp(target)
	local output = git.get_modified_timestamp(config_dir, target)
	local ts = tonumber(output)
	if ts and ts % 1 == 0 then
		return ts
	end
end

local function iso_8601_to_unix(url)
	local response = request.get_json(url)
	local date = response.commit.committer.date
	local year, month, day, hour, min, sec = date:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
	return os.time({
		year = year,
		month = month,
		day = day,
		hour = hour,
		min = min,
		sec = sec,
		isdst = false,
	})
end

local function get_latest_tag_commit_url()
	local response = request.get_json(tags_url)
	for _, tag in ipairs(response) do
		if tag.name == "latest" then
			return tag.commit.url
		end
	end
end

local function get_main_commit_url()
	local response = request.get_json(main_branch_url)
	return response.commit.url or nil
end

local function update_if_needed(local_ts, remote_ts)
	if local_ts < remote_ts then
		print("HIER")
		os.exit(1)
	end
	os.exit(0)
end

local target_type = git.is_tag_or_branch(config_dir)
if target_type == "tag" then
	local local_ts = get_local_timestamp("latest")
	local remote_ts = iso_8601_to_unix(get_latest_tag_commit_url())
	return update_if_needed(local_ts, remote_ts)
elseif target_type == "branch" then
	local local_ts = get_local_timestamp("main")
	print(local_ts)
	local remote_ts = iso_8601_to_unix(get_main_commit_url())
	print(remote_ts)
	return update_if_needed(local_ts, remote_ts)
end
os.exit(0)
