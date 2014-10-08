local IRC = require "luvit-irc"
local Formatting = require "luvit-irc/lib/formatting"
local GithubPoller = require "./lib/githubpoller"
local table = require "table"

local config_file = process.argv[1] or "config"
local config = require ("./"..config_file)

local irc_connection = IRC:new (config.server, config.nick, {auto_connect=true, auto_join=config.channels})
local pollers = {}

if config.github then
	local github_poller = GithubPoller:new(config.github)
	table.insert(pollers, github_poller)
end

irc_connection:on ("connecting", function()
	p ("Connecting to "..irc_connection.server.."...")
end)
irc_connection:on ("connect", function(welcomemsg, server, nick)
	p ("Connected to "..server.." as "..nick)
	for _,poller in ipairs(pollers) do
		poller:start()
	end
end)
irc_connection:on ("connecterror", function(reason, err)
	p ("Could not connect to "..irc_connection.server..": "..reason)
end)
irc_connection:on ("disconnect", function(reason, err)
	p ("Disconnected from "..irc_connection.server..": "..reason)
	for _,poller in ipairs(pollers) do
		poller:stop()
	end
end)
irc_connection:on ("ijoin", function(channel)
	p ("Joined channel "..channel.name)
end)
irc_connection:on ("ipart", function(channel, reason)
	p ("Left channel "..channel.name)
end)

for _,poller in ipairs(pollers) do
	poller:on ("data", function(string_to_send)
		if irc_connection.connected then
			irc_connection:say("#", string_to_send)
		end
		Formatting.print(string_to_send)
	end)
end