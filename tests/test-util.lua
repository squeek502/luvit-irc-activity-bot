require("tap")(function(test)
	local util = require "../lib/util"
	local os = require "os"

	local now_time = os.time()
	local now_date = util.date.ISO_8601(now_time)

	test("date.ISO_8601", function()
		assert(now_date == util.date.ISO_8601())
	end)

	test("events.delta", function()
		assert(util.events.delta(nil, nil, nil) == nil)

		local events = {{created_at=now_date}}
		assert(events == util.events.delta(events, nil, nil))
		assert(0 == #util.events.delta(events, events))

		local older_time = now_time - 1
		local older_date = util.date.ISO_8601(older_time)
		local older_events = {{created_at=older_date}}
		assert(#events == #util.events.delta(events, older_events, nil))

		local newer_time = now_time + 1
		local newer_date = util.date.ISO_8601(newer_time)
		local newer_events = {{created_at=newer_date}}
		assert(0 == #util.events.delta(events, newer_events, nil))

		assert(0 == #util.events.delta(events, nil, now_time))
		assert(#events == #util.events.delta(events, nil, older_time))
		assert(0 == #util.events.delta(events, nil, newer_time))

		assert(0 == #util.events.delta(events, nil, now_date))
		assert(#events == #util.events.delta(events, nil, older_date))
		assert(0 == #util.events.delta(events, nil, newer_date))
	end)

end)
