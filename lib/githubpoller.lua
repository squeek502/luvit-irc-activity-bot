local Poller = require "luvit-poller"
local Cache = require "./cache"
local EventHandler = require "./eventhandler"
local get = require "./get"
local util = require "./util"
local string = require "string"
local table = require "table"
local os = require "os"
local JSON = require "json"
local Emitter = require "core".Emitter

local GithubPoller = Emitter:extend()

function GithubPoller:initialize(settings)
	self.users = {}
	self.repos = {}
	self.gists = {}
	self.pollers = {}
	self.caches = {}

	settings = settings or {}
	settings.users = settings.users or {}
	settings.repos = settings.repos or {}
	settings.gists = settings.gists or {}

	for _,user in ipairs(settings.users) do
		self:adduser(user)
	end
	for _,repo in ipairs(settings.repos) do
		self:addrepo(repo)
	end
	for _,gist in ipairs(settings.gists) do
		self:addgist(gist)
	end
end

function GithubPoller:start()
	for _,poller in ipairs(self.pollers) do
		poller:start()
	end
end

function GithubPoller:stop()
	for _,poller in ipairs(self.pollers) do
		poller:stop()
	end
end

function GithubPoller:initpoller(poller, pollertype)
	local cache = Cache:new(poller)
	table.insert(self.pollers, poller)
	table.insert(self.caches, cache)

	if not cache.data then
		poller.headers["If-Modified-Since"] = util.date.RFC_1123()
	end

	poller:on("polling", function()
	end)
	poller:on("error", function(err)
		p(err)
	end)
	poller:on("notmodified", function(msg)
	end)
	poller:on("data", function(data, response)
		if response.statusCode ~= 200 then
			p("Unexpected response status code: ", response.statusCode)
			return
		end

		local events = JSON.parse(data)
		local delta = util.events.delta(events, cache.data)
		cache:put(events)

		for _,event in ipairs(delta) do
			local ignore = false
			-- ignore overlap between user and repository events
			ignore = ignore or (pollertype == "user" and event.repo and self.repos[event.repo.name] ~= nil)
			if not ignore then
				local msg_string = EventHandler.stringify(event)
				self:emit("data", msg_string)
			end
		end
	end)
end

function GithubPoller:adduser(user)
	self:addeventsofuser(user)
	self:addreposofuser(user)
	self:addgistsofuser(user)
end

function GithubPoller:addrepo(reponame)
	local repo_events_url = string.format("https://api.github.com/repos/%s/events", reponame)
	local repo_events_poller = Poller:new(repo_events_url)
	self.repos[reponame] = repo_events_poller
	self:initpoller(repo_events_poller, "repo")
	p("[GithubPoller] Tracking repository events: "..reponame)
end

function GithubPoller:addgist(gistid)
	--[[
	-- TODO
	local gist_commits_url = string.format("https://api.github.com/gists/%s/commits", gistid)
	local gist_commits_poller = Poller:new(gist_commits_url)
	self.gists[gistid] = gist_commits_poller
	self:initpoller(gist_commits_poller, "gist")
	]]--
end

function GithubPoller:addeventsofuser(user)
	local user_events_url = string.format("https://api.github.com/users/%s/events/public", user)
	local user_events_poller = Poller:new(user_events_url)
	self.users[user] = user_events_poller
	self:initpoller(user_events_poller, "user")
	p("[GithubPoller] Tracking user events: "..user)
end

function GithubPoller:addreposofuser(user)
	get(string.format("https://api.github.com/users/%s/repos", user), function(err, data, response)
		if err then
			p(err, data)
			return
		end
		local parsed = JSON.parse(data)
		for _,repo in ipairs(parsed) do
			self:addrepo(repo.full_name)
		end
	end)
end

function GithubPoller:addgistsofuser(user)
	--[[
	-- TODO
	get(string.format("https://api.github.com/users/%s/gists", user), function(err, data, response)
		if err then
			p(err, data)
			return
		end
		local parsed = JSON.parse(data)
		for _,gist in ipairs(parsed) do
			self:addgist(gist.id)
		end
	end)
	]]--
end

return GithubPoller