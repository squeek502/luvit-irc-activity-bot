require("luvit-test/helper")

local Cache = require "../lib/cache"
local Poller = require "luvit-poller"
local FS = require "fs"
local Path = require "path"

local cachedir = Path.join("tmp", "\"Illegal Filename\"")
local dummypoller = Poller:new("http://dummy/url/")

local cache = Cache:new(dummypoller, cachedir)

-- should not cause an error whether or not the files can be written
assert(pcall(cache.put, cache, {}))