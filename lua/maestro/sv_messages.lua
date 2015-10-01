maestro.hook("CheckPassword", "maestro_messages", function(id64, ip, sv, cl, name)
	local id = util.SteamIDFrom64(id64)
	local ban = maestro.bans and maestro.bans[id] or false
	if ban and ban.unban > os.time() then
		return
	end
	if sv ~= "" and sv ~= cl then
		maestro.chat(false, Color(255, 255, 255), "Player ", Color(78, 196, 255), name, Color(255, 255, 255), " (", Color(78, 196, 255), util.SteamIDFrom64(id64), Color(255, 255, 255), ") tried to connect to the server with incorrect password \"", cl, "\".")
	else
		maestro.chat(nil, Color(255, 255, 255), "Player ", Color(78, 196, 255), name, Color(255, 255, 255), " (", Color(78, 196, 255), util.SteamIDFrom64(id64), Color(255, 255, 255), ") has connected to the server.")
	end
end)
maestro.hook("PlayerInitialSpawn", "maestro_messages", function(ply)
	maestro.chat(nil, Color(255, 255, 255), "Player ", Color(78, 196, 255), ply:Nick(), Color(255, 255, 255), " (", Color(78, 196, 255), ply:SteamID(), Color(255, 255, 255), ") has joined the game.")
end)
maestro.hook("PlayerDisconnected", "maestro_messages", function(ply)
	maestro.chat(nil, Color(255, 255, 255), "Player ", Color(78, 196, 255), ply:Nick(), Color(255, 255, 255), " (", Color(78, 196, 255), ply:SteamID(), Color(255, 255, 255), ") has left the game.")
end)
