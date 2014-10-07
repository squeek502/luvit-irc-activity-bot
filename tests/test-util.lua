require("luvit-test/helper")

local util = require "../lib/util"
local os = require "os"

assert_equal(nil, util.events.delta(nil, nil, nil))

local now_time = os.time()
local now_date = util.date.ISO_8601(now_time)
assert_equal(now_date, util.date.ISO_8601())

local events = {{created_at=now_date}}
assert_equal(events, util.events.delta(events, nil, nil))
assert_deep_equal({}, util.events.delta(events, events))

local older_time = now_time - 1
local older_date = util.date.ISO_8601(older_time)
local older_events = {{created_at=older_date}}
assert_deep_equal(events, util.events.delta(events, older_events, nil))

local newer_time = now_time + 1
local newer_date = util.date.ISO_8601(newer_time)
local newer_events = {{created_at=newer_date}}
assert_deep_equal({}, util.events.delta(events, newer_events, nil))

assert_deep_equal({}, util.events.delta(events, nil, now_time))
assert_deep_equal(events, util.events.delta(events, nil, older_time))
assert_deep_equal({}, util.events.delta(events, nil, newer_time))

assert_deep_equal({}, util.events.delta(events, nil, now_date))
assert_deep_equal(events, util.events.delta(events, nil, older_date))
assert_deep_equal({}, util.events.delta(events, nil, newer_date))
