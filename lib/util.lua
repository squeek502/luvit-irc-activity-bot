local table = require "table"
local os = require "os"

local util = { date = {}, events = {} }

util.events.delta = function(newer, older, retrieved)
	if (not older or #older == 0) and not retrieved then return newer end
	local latest_seen = (older and older[1]) and older[1] or {}
	local latest_seen_date = latest_seen.created_at
	if not latest_seen_date then
		latest_seen_date = type(retrieved) == "number" and util.date.ISO_8601(retrieved) or retrieved
	end
	local delta = {}
	for i,event in ipairs(newer) do
		if event.created_at > latest_seen_date then
			table.insert(delta, event)
		end
	end
	return delta
end

util.date.RFC_1123 = function(time)
	-- Sun, 06 Nov 1994 08:49:37 GMT
	return os.date("!%a, %d %b %Y %H:%M:%S GMT", time)
end

util.date.ISO_8601 = function(time)
	-- 2014-10-07T20:08:59Z
	return os.date("!%Y-%m-%dT%H:%M:%SZ", time)
end

return util