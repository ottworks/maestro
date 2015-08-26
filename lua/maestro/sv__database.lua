if not file.Exists("maestro", "DATA") then
	file.CreateDir("maestro")
end

--[[
	Use these functions to define custom save/load operations. Note that your
	data plugin should be in lua/maestro and should be named so that it comes
	alphabetically after sv__database and before sv__zzzz, as later files use
	database functionality.

	Example code:
	maestro.definedataproc("ranks", function(name, tab)
		saveSomeThingOrMaybeConvertItToADifferentStructureTheChoiceIsYours(tab)
	end, function(name, callback)
		local tab = loadSomeThingOrDoSomethingMoreComplexIDontKnowYouDontNeedNoMan(name)
		callback(tab)
	end)
--]]
local dataprocs = {}
function maestro.definedataproc(type, save, load)
	dataprocs[type] = {
		save = save,
		load = load,
	}
end

local logprocs = {}
function maestro.definelogproc(type, log, read)
	logprocs[type] = {
		log = log,
		read = read,
	}
end

function maestro.load(name, callback)
	if dataprocs[name] then
		dataprocs[name].load(name, callback)
	else
		local newfile = false
		if not file.Exists("maestro/" .. name .. ".txt", "DATA") then
			file.Write("maestro/" .. name .. ".txt", "")
			newfile = true
		end
		callback(util.JSONToTable(file.Read("maestro/" .. name .. ".txt")) or {}, newfile)
	end
end

function maestro.save(name, tab)
	if dataprocs[name] then
		return dataprocs[name].save(name, tab)
	else
		file.Write("maestro/" .. name .. ".txt", util.TableToJSON(tab))
	end
end

function maestro.log(name, item)
	if logprocs[name] then
		logprocs[name].log(name, item)
	else
		if type(item) == "table" then item = util.TableToJSON(item) end
		if not file.Exists("maestro/" .. name .. ".txt", "DATA") then
			file.Write("maestro/" .. name .. ".txt", "")
		end
		file.Append("maestro/" .. name .. ".txt", item .. "\n")
	end
end

function maestro.read(name, iterator)
	if logprocs[name] then
		return logprocs[name].read(name, iterator)
	else
		local ret = {}
		if iterator then
			return string.gmatch(file.Read("maestro/" .. name .. ".txt"), "[^\n]+")
		end

		for w in string.gmatch(file.Read("maestro/" .. name .. ".txt"), "[^\n]+") do
			ret[#ret + 1] = w
		end
		return ret
	end
end
