local http = require("http")
local https = require("https")
local parse_url = require("url").parse

local get = function(url, callback)
	local parsed_url = parse_url(url)
	local protocol = parsed_url.protocol or "http"
	local getfn = protocol == "https" and https.get or http.get

	local request = getfn(
	{
		protocol = protocol,
		host = parsed_url.hostname,
		port = port,
		path = parsed_url.pathname or "/",
		headers = { {"User-Agent", "luvit-irc-activity-bot"} }
	}, 
	function (response)
		local data = ""
		response:on("data", function (chunk)
			data = data .. chunk
		end)
		response:on("error", function(err)
			callback("Error while receiving a response: " .. tostring(err), err)
		end)
		response:on("end", function ()
			callback(nil, data, response)
		end)
	end)
	request:on("error", function(err)
		callback("Error while sending a request: " .. tostring(err), err)
	end)
	request:done()
end

return get