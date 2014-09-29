local table = require "table"

local util = { table = {}, events = {} }

util.table.deep_equal = function(a, b)
	if type(a) == 'table' and type(b) == 'table' then
		if #a ~= #b then return false end
		for k, v in pairs(a) do
			if not util.table.deep_equal(v, b[k]) then return false end
		end
		return true
	else
		return a == b
	end
end

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

-- not working right for our purposes
util.table.delta = function(newer, older)
	local delta = {}
	if type(newer) ~= "table" then return delta end
	local olderi = 1
	for i,val in ipairs(newer) do
		local olderval = older and older[olderi]
		if util.table.deep_equal(val, olderval) then
			olderi = olderi + i
		else
			table.insert(delta, val)
		end
	end
	return delta
end

return util