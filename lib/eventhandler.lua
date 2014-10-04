local string = require("string")
local table = require("table")
local irc_util = require("luvit-irc/lib/util")
local Formatting = require("luvit-irc/lib/formatting")
local Colors = Formatting.Colors
local colorize = Formatting.colorize
local Styles = Formatting.Styles
local stylize = Formatting.stylize

local function url(url)
	url = url:gsub("(.+)://api%.([^/]+)/[^/]+/(.*)", "%1://%2/%3")
	return colorize("[", Colors.LIGHT_GRAY)..colorize(url, Colors.GRAY)..colorize("]", Colors.LIGHT_GRAY)
end

local function resolve_branch(branchref)
	return branchref:gsub("refs/heads/", "")
end

local function tagorbranch(hash)
	return colorize(hash, Colors.MAGENTA)
end

local function branch(branchref)
	return tagorbranch(resolve_branch(branchref))
end

local function commits_url(repo_url, branchref)
	return url(repo_url.."/commits/"..resolve_branch(branchref))
end

local function plaintext(text, maxlen)
	maxlen = maxlen or 32
	text = text:gsub("[\r\n]+", ". ")
	if text:len() > maxlen then 
		text = text:sub(1, maxlen).."..."
	end
	return "'"..text.."'"
end

local function repo(name)
	return colorize(name, Colors.DARK_RED)
end

local function issue(number)
	return colorize("#"..number, Colors.MAGENTA)
end

local function user(name)
	return colorize(stylize(name, Styles.BOLD), Colors.LIGHT_RED)
end

local function committer(name)
	return colorize(name, Colors.LIGHT_BLUE)
end

local function commit(hash)
	return colorize(hash, Colors.MAGENTA)
end

local handlers = {
	CommitCommentEvent = function(event, payload)
		return string.format("%s commented on commit %s%s: %s %s",
			user(payload.comment.user.login),
			commit("@"..payload.comment.commit_id:sub(1,5)),
			repo(event.repo.name),
			plaintext(payload.comment.body),
			url(payload.comment.html_url))
	end,
	CreateEvent = function(event, payload)
		return string.format("%s created a new %s (%s) %s",
			user(event.actor.login),
			payload.ref_type,
			repo(event.repo.name) .. (payload.ref and tagorbranch("@"..payload.ref) or ""),
			url(event.repo.url))
	end,
	DeleteEvent = function(event, payload)
		return string.format("%s deleted the %s %s from %s %s",
			user(event.actor.login),
			tagorbranch(payload.ref),
			payload.ref_type,
			repo(event.repo.name),
			url(event.repo.url))
	end,
	ForkEvent = function(event, payload)
		return string.format("%s forked %s to %s %s",
			user(event.actor.login),
			repo(event.repo.name),
			repo(payload.forkee.full_name),
			url(payload.forkee.html_url))
	end,
	GollumEvent = function(event, payload)
		return string.format("%s edited or created %d wiki page(s) of %s %s",
			user(event.actor.login),
			#payload.pages,
			repo(event.repo.name),
			url(event.repo.url))
	end,
	IssueCommentEvent = function(event, payload)
		return string.format("%s commented on issue %s%s (%s): %s %s",
			user(payload.comment.user.login),
			repo(event.repo.name),
			issue(payload.issue.number),
			plaintext(payload.issue.title),
			plaintext(payload.comment.body),
			url(payload.comment.html_url))
	end,
	IssuesEvent = function(event, payload)
		local actiondescription = repo(event.repo.name)..issue(payload.issue.number)
		if payload.assignee ~= nil then 
			actiondescription = actiondescription .. " to " .. user(payload.assignee.login)
		elseif payload.label ~= nil then
			actiondescription = actiondescription .. " with " .. tagorbranch(payload.label.name)
		end
		return string.format("%s %s issue %s (%s) %s",
			user(event.actor.login),
			payload.action,
			actiondescription,
			plaintext(payload.issue.title),
			url(payload.issue.html_url))
	end,
	MemberEvent = function(event, payload)
		return string.format("%s was %s as a collaborator to %s %s",
			user(payload.member.login),
			payload.action,
			repo(event.repo.name),
			url(event.repo.url))
	end,
	PublicEvent = function(event, payload)
		return string.format("%s just open sourced %s %s",
			user(payload.member.login),
			repo(event.repo.name),
			url(event.repo.url))
	end,
	PullRequestEvent = function(event, payload)
		local action = payload.action
		if action == "closed" and payload.pull_request.merged then
			action = "merged"
		end
		local actiondescription = repo(event.repo.name)..issue(payload.number)
		if payload.assignee ~= nil then 
			actiondescription = actiondescription .. " to " .. user(payload.assignee.login)
		elseif payload.label ~= nil then
			actiondescription = actiondescription .. " with " .. tagorbranch(payload.label.name)
		end
		return string.format("%s %s pull request %s (%s) %s",
			user(event.actor.login),
			action,
			actiondescription,
			plaintext(payload.pull_request.title),
			url(payload.pull_request.html_url))
	end,
	PullRequestReviewCommentEvent = function(event, payload)
		return string.format("%s commented on the diff of pull request %s (%s): %s %s",
			user(event.actor.login),
			repo(event.repo.name)..issue(payload.number),
			plaintext(payload.pull_request.title),
			plaintext(payload.comment.body),
			url(payload.pull_request.html_url))
	end,
	PushEvent = function(event, payload)
		local commitlines = {}
		table.insert(commitlines, string.format("%s pushed %d commit(s) to %s%s %s",
			user(event.actor.login),
			payload.size,
			repo(event.repo.name),
			branch("@"..payload.ref),
			commits_url(event.repo.url, payload.ref))
		)
		for _,commit in ipairs(payload.commits) do
			table.insert(commitlines, string.format("%s%s: %s",
				colorize("-> ", Colors.GRAY),
				committer(commit.author.username or commit.author.name),
				plaintext(commit.message, 64))
			)
		end
		return irc_util.string.join(commitlines, "\r\n")
	end,
	ReleaseEvent = function(event, payload)
		return string.format("%s released %s %s",
			user(event.actor.login),
			payload.release.name or (repo(event.repo.name)..tagorbranch("@"..payload.release.tag_name)),
			url(payload.release.html_url))
	end,
	WatchEvent = function(event, payload)
		return string.format("%s starred %s %s",
			user(event.actor.login),
			repo(event.repo.name),
			url(event.repo.url))
	end,
}

local function _tostring(event)
	if handlers[event.type] ~= nil then
		return handlers[event.type](event, event.payload)
	end
end

return { stringify=_tostring }