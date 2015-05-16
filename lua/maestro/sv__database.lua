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