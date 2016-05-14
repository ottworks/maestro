maestro.command("ban", {"player:target", "time", "reason"}, function(caller, targets, time, reason)
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	elseif #targets > 1 then
		return true, "Query matched more than 1 player."
	end
	local ply = targets[1]
	maestro.ban(ply, time, reason, caller)
	return false, "banned %1 for %2 (%3)"
end, [[
Bans the player for the specified time and reason.]])
maestro.command("banid", {"steamid", "time", "reason"}, function(caller, id, time, reason)
	maestro.ban(id, time, reason, caller)
	return false, "banned %1 for %2 (%3)"
end, [[
Bans the SteamID for the specified time and reason.
Any currently connected players with this SteamID will be kicked.]])
maestro.command("unban", {"steamid", "reason:optional"}, function(caller, id, reason)
	maestro.unban(util.SteamIDTo64(id), reason, caller and IsValid(caller) and caller:SteamID64() or 0)
	if reason then
		return false, "unbanned %1 (%2)"
	end
	return false, "unbanned %1"
end)

if SERVER then
	util.AddNetworkString("maestro_banlog")
end
maestro.command("banlog", {"player:target"}, function(caller, targets)
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	elseif #targets > 1 then
		return true, "Query matched more than 1 player."
	end
	local id = targets[1]:SteamID()
	local q = mysql:Select("maestro_bans")
		q:Where("steamid", util.SteamIDTo64(id))
		q:Callback(function(res, status)
			if type(res) == "table" then
				table.sort(res, function(a, b) return a.id < b.id end)
				maestro.chatconsole(caller, Color(255, 255, 255), "Banlog for (", maestro.blue, id, Color(255, 255, 255), "):")
				for i = 1, #res do
					local ban = res[i]
					local col = tonumber(ban["until"]) > os.time() and maestro.orange or maestro.blue
					local len = ban["until"] == 0 and "permanent" or maestro.time(ban["until"] - ban.when)
					maestro.chatconsole(caller, col, "\t", os.date("%x - ", ban.when), "#", ban.id, ", ", ban.admin, " (", util.SteamIDFrom64(ban.adminid), "): ", Color(255, 255, 255), ban.reason, col, " Length: ", Color(255, 255, 255), len)
				end
			end
		end)
	q:Execute()
end, [[
Displays a history of bans and unbans for the specified player.]])
maestro.command("banlogid", {"id"}, function(caller, id)
	local q = mysql:Select("maestro_bans")
		q:Where("steamid", util.SteamIDTo64(id))
		q:Callback(function(res, status)
			if type(res) == "table" then
				table.sort(res, function(a, b) return a.id < b.id end)
				maestro.chatconsole(caller, Color(255, 255, 255), "Banlog for (", maestro.blue, id, Color(255, 255, 255), "):")
				for i = 1, #res do
					local ban = res[i]
					local col = tonumber(ban["until"]) > os.time() and maestro.orange or maestro.blue
					local len = ban["until"] == 0 and "permanent" or maestro.time(ban["until"] - ban.when)
					maestro.chatconsole(caller, col, "\t", os.date("%x - ", ban.when), "#", ban.id, ", ", ban.admin, " (", util.SteamIDFrom64(ban.adminid), "): ", Color(255, 255, 255), ban.reason, col, " Length: ", Color(255, 255, 255), len)
				end
			end
		end)
	q:Execute()
end, [[
Displays a history of bans and unbans for the specified SteamID.]])
