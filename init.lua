local IRC = require "luvit-irc"
local Formatting = require "luvit-irc/lib/formatting"
local GithubPoller = require "./lib/githubpoller"
local config = require "./config"

local irc_connection = IRC:new (config.server, config.nick, {auto_connect=true, auto_join=config.channels})

local github_poller = GithubPoller:new({users={"octocat"}, repos={"luvit/luvit"}})

irc_connection:on ("connecting", function()
	p ("Connecting to "..irc_connection.server.."...")
end)
irc_connection:on ("connect", function(welcomemsg, server, nick)
	p ("Connected to "..server.." as "..nick)
	github_poller:start()
end)
irc_connection:on ("disconnect", function(reason, server, nick, options)
	p ("Disconnected from "..server..": "..reason)
	github_poller:stop()
end)
irc_connection:on ("ijoin", function(channel)
	p ("Joined channel "..channel.name)
end)
irc_connection:on ("ipart", function(channel, reason)
	p ("Left channel "..channel.name)
end)

github_poller:on ("data", function(string_to_send)
	if irc_connection.connected then
		irc_connection:say("#", string_to_send)
	end
	Formatting.print(string_to_send)
end)