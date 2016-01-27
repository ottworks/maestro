include("mysql.lua")

local config = maestro.config

hook.Add("maestro_postload", "database", function()
	mysql:SetModule(config.module)
	function mysql:OnConnected()
		MsgC(Color(25, 235, 25), "[mysql] Connected to the database!\n")
		hook.Call("DatabaseConnected", nil)
		hook.Call("maestro_pluginload")
	end
	function mysql:OnConnectionFailed(errorText)
		ErrorNoHalt("[mysql] Unable to connect to the database!\n"..errorText.."\n")
		hook.Call("DatabaseConnectionFailed", nil, errorText)
		hook.Call("maestro_pluginload")
	end
	mysql:Connect(config.host, config.username, config.password, config.database, config.port, config.socket)
end)

if not file.Exists("maestro", "DATA") then
	file.CreateDir("maestro")
end


function maestro.load(name, callback)
	local newfile = false
	if not file.Exists("maestro/" .. name .. ".txt", "DATA") then
		file.Write("maestro/" .. name .. ".txt", "")
		newfile = true
	end
    if callback then
        callback(util.JSONToTable(file.Read("maestro/" .. name .. ".txt")), newfile)
    else
        return util.JSONToTable(file.Read("maestro/" .. name .. ".txt")), newfile
    end
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
