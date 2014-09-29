require("luvit-test/helper")

local util = require "../lib/util"

-- util.table.deep_equal
assert(util.table.deep_equal({a=1}, {a=1}))
assert(not util.table.deep_equal({a=1}, nil))

-- util.table.delta
assert_deep_equal({"test"}, util.table.delta({"test"}, nil))
assert_deep_equal({}, util.table.delta(nil, {"test"}))
assert_deep_equal({{c=3, d=4}}, util.table.delta({{a=1, b=2}, {c=3, d=4}}, {{a=1, b=2}}))
assert_deep_equal({{a=1, b=2}}, util.table.delta({{a=1, b=2}, {c=3, d=4}}, {{c=3, d=4}}))