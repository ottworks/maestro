maestro.bans = maestro.load("bans")

function maestro.ban(id, time, reason)
	local ply
	if type(id) == "Player" then
		ply = id
		id = id:SteamID()
	end
	if player.GetBySteamID and player.GetBySteamID(id) then
		ply = player.GetBySteamID(id)
	end
	if ply then
		if time == 0 then
			ply:Kick("Permabanned: " .. reason)
		else
			local unban = "\n(" .. maestro.time(time, 2) .. " remaining)"
			ply:Kick("Banned: " .. string.sub(reason, 1, 255 - 8 - #unban) .. unban)
		end
	end
	
	local prevbans = 1
	if maestro.bans[id] then
		prevbans = (maestro.bans[id].prevbans or 0	) + 1
	end
	maestro.bans[id] = {unban = os.time() + time, reason = reason, prevbans = prevbans, perma = (time == 0)}
	maestro.save("bans", maestro.bans)
end

hook.Add("CheckPassword", "maestro_bans", function(id64)
	local id = util.SteamIDFrom64(id64)
	local ban = maestro.bans[id]
	if ban then
		if ban.unban > os.time() then
			local unban = "\n(" .. maestro.time(ban.unban - os.time(), 2) .. " remaining)"
			return false, "Banned: " .. string.sub(ban.reason, 1, 255 - 8 - #unban) .. unban
		elseif ban.perma then
			return false, "Permabanned: " .. ban.reason
		end
	end
end)