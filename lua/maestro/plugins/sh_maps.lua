if SERVER then
	maestro.maps = maestro.load("bans")
end
local nominated = {}
local rtv = {}
maestro.command("map", {"map"}, function(caller, map)
	map = map:gsub(";", "")
	if not file.Exists("maps/" .. map .. ".bsp", "GAME") then
		return true, "Map not found: " .. map .. ".bsp"
	end
	RunConsoleCommand("changelevel", map)
	return false, "changed the level to %1"
end)
maestro.command("nominate", {"map"}, function(caller, map)
	if not file.Exists("maps/" .. map .. ".bsp", "GAME") then
		return true, "Map not found: " .. map .. ".bsp"
	end
	if nominated[map] then
		return true, "Map has already been nominated for!"
	end
	nominated[map] = true
	return false, "nominated map %1"
end)
maestro.command("rtv", {}, function(caller)
	if not rtv[caller] then
		rtv[caller] = true
		rtv.count = (rtv.count or 0) + 1
		local c = rtv.count
		local t = #player.GetAll()
		local p = c/t
		local r = math.ceil(0.75 * t)
		if c >= r then
			local maps = {}
			for map in RandomPairs(nominated) do
				if #maps >= 5 then break end
				maps[#maps + 1] = map
			end
			local files = file.Find("maps/*.bsp", "GAME")
			for _, map in RandomPairs(files) do
				if #maps >= 5 then break end
				maps[#maps + 1] = map:sub(1, -5)
			end
			maestro.vote("Vote for the next map!", maps, function(option, voted, total)
				nominated = {}
				rtv = {}
				if option and file.Exists("maps/" .. option .. ".bsp", "GAME") then
					maestro.chat(nil, Color(255, 255, 255), "Option \"", option, "\" has won. (", voted, "/", total, ")")
					maestro.chat(nil, Color(255, 255, 255), "Map change in 3 seconds.")
					timer.Simple(3, function()
						RunConsoleCommand("changelevel", option)
					end)
				else
					maestro.chat(nil, Color(255, 255, 255), "No options have won.")
				end
			end)
		end
		return false, "wants to rock the vote (" .. c .. "/" .. r .. ")"
	end
	return true, "You have already rocked the vote!"
end)
