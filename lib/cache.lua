local Object = require "core".Object
local Path = require "path"
local FS = require "fs"
local os = require "os"
local JSON = require "json"

local function recursive_mkdir(path)
	if path and path ~= "" and not FS.existsSync(path) then
		recursive_mkdir(Path.dirname(path))
		FS.mkdirSync(path, "")
	end
end

local Cache = Object:extend()

function Cache:initialize(poller, rootdir)
	self.poller = poller
	self.rootdir = (rootdir or "cache")
	self.info, self.data = self:get()
	if self.info then
		self.poller.etag = self.info.etag
		self.poller.last_poll = self.info.retrieved
	end
end

function Cache:getfilenames()
	local subdirs = self.poller.parsed_url.pathname:gsub("/", Path.getSep and Path:getSep() or Path.sep)
	local cachedir = Path.join(self.rootdir, self.poller.parsed_url.hostname, subdirs)

	local infofilename = Path.join(cachedir, "info.json")
	local datafilename = Path.join(cachedir, "cache.json")

	return infofilename, datafilename
end

function Cache:put(data)
	self.info = { retrieved = self.poller.last_poll or os.time(), etag = self.poller.etag }
	self.data = data

	local ok, err = pcall(Cache._write, self)
end

function Cache:_write()
	local stringinfo = JSON.stringify(self.info)
	local stringdata = JSON.stringify(self.data)

	local infofilename, datafilename = self:getfilenames()
	recursive_mkdir(Path.dirname(infofilename))
	recursive_mkdir(Path.dirname(datafilename))

	if FS.existsSync(infofilename) then
		FS.unlinkSync(infofilename)
	end
	FS.writeFile(infofilename, stringinfo, function(err)
		if err then
			error(err)
		end
	end)

	if FS.existsSync(datafilename) then
		FS.unlinkSync(datafilename)
	end
	FS.writeFile(datafilename, stringdata, function(err)
		if err then
			error(err)
		end
	end)
end

function Cache:get()
	if not self.info or not self.data then
		local ok, readinfo, readdata = pcall(Cache._read, self)
		if ok then
			self.info = readinfo or self.info
			self.data = readdata or self.data
		end
	end
	return self.info, self.data
end

function Cache:_read()
	local infofilename, datafilename = self:getfilenames()

	local cachedinfo = nil
	if FS.existsSync(infofilename) then
		cachedinfo = FS.readFileSync(infofilename)
		cachedinfo = cachedinfo and JSON.parse(cachedinfo)
	end

	local cacheddata = nil
	if FS.existsSync(datafilename) then
		cacheddata = FS.readFileSync(datafilename)
		cacheddata = cacheddata and JSON.parse(cacheddata)
	end

	return cachedinfo, cacheddata
end

return Cache