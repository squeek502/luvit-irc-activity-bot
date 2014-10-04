local table = require "table"
local os = require "os"

local util = { date = {}, events = {} }

util.events.delta = function(newer, older)
	if not older or #older == 0 then return newer end
	local latest_seen = older[1]
	local latest_seen_date = latest_seen.created_at
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
	return os.date("%a, %d %b %Y %H:%M:%S GMT", time)
end

return util