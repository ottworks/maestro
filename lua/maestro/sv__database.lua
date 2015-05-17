if not file.Exists("maestro", "DATA") then
	file.CreateDir("maestro")
end

function maestro.load(name)
	local newfile = false
	if not file.Exists("maestro/" .. name .. ".txt", "DATA") then
		file.Write("maestro/" .. name .. ".txt", "")
		newfile = true
	end
	return util.JSONToTable(file.Read("maestro/" .. name .. ".txt")) or {}, newfile
end

function maestro.save(name, tab)
	file.Write("maestro/" .. name .. ".txt", util.TableToJSON(tab))
end

function maestro.log(name, item)
	if type(item) == "table" then item = util.TableToJSON(item) end
	if not file.Exists("maestro/" .. name .. ".txt", "DATA") then
		file.Write("maestro/" .. name .. ".txt", "")
	end
	file.Append("maestro/" .. name .. ".txt", item .. "\n")
end

function maestro.read(name, iterator)
	local ret = {}
	if iterator then
		return string.gmatch(file.Read("maestro/" .. name .. ".txt"), "[^\n]+")
	end
	
	for w in string.gmatch(file.Read("maestro/" .. name .. ".txt"), "[^\n]+") do
		ret[#ret + 1] = w
	end
	return ret
end