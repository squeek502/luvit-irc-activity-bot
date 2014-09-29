local IRC = require "luvit-irc"
local Poller = require "luvit-poller"
local JSON = require "json"
local Path = require "path"
local FS = require "fs"
local config = require "./config"
local EventHandler = require "./lib/eventhandler"
local Cache = require "./lib/cache"
local util = require "./lib/util"
local Formatting = require "luvit-irc/modules/irc/formatting"

local irc_connection = IRC:new (config.server, config.nick, {auto_connect=true, auto_join=config.channels})
local event_poller = Poller:new("https://api.github.com:443/users/squeek502/events/public")
local event_cache = Cache:new(event_poller)

irc_connection:on ("connect", function(welcomemsg, server, nick)
	p ("Connected to "..server.." as "..nick)
	event_poller:start()
end)
irc_connection:on ("disconnect", function(reason, server, nick, options)
	p ("Disconnected from "..server..": "..reason)
	event_poller:stop()
end)
irc_connection:on ("ijoin", function(channel)
	p ("Joined channel "..channel.name)
end)
irc_connection:on ("ipart", function(channel, reason)
	p ("Left channel "..channel.name)
end)

event_poller:on("error", function(err)
	p(err)
end)
event_poller:on("notmodified", function(msg)
	p(msg)
end)
event_poller:on("data", function(data, response)
	if response.statusCode ~= 200 then
		p("Unexpected response status code: ", response.statusCode)
		return
	end

	local events = JSON.parse(data)
	local delta = util.events.delta(events, event_cache.data)

	p("got "..(#events).." events ("..(#delta).." new)")

	event_cache:put(events)

	-- bad flood protection
	-- TODO: improve this
	if #delta < 5 then
		for _,event in ipairs(delta) do
			local string_to_send = EventHandler.stringify(event)
			irc_connection:say("#", string_to_send)
			Formatting.print(string_to_send)
		end
	end
end)
