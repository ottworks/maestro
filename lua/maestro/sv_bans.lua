maestro.load("bans", function(val)
	maestro.bans = val
end)

function maestro.ban(id, time, reason)
	if not maestro.bans then return end
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

	local prevbans = 0
	if maestro.bans[id] then
		prevbans = maestro.bans[id].prevbans + 1
	end
	maestro.bans[id] = {unban = os.time() + time, reason = reason, prevbans = prevbans, perma = (time == 0)}
	maestro.save("bans", maestro.bans)

	maestro.log("banlog", {type = "ban", id = id, date = os.time(), length = time, reason = reason, prevbans = prevbans, perma = (time == 0)})
end
function maestro.unban(id, reason)
	if not maestro.bans then return end
	local ban = maestro.bans[id]
	if ban then
		maestro.bans[id] = {unban = os.time(), reason = ban.reason, prevbans = ban.prevbans, perma = false}
		maestro.save("bans", maestro.bans)
		maestro.log("banlog", {type = "unban", id = id, reason = reason, date = os.time()})
	end
end

maestro.hook("CheckPassword", "maestro_bans", function(id64)
	if not maestro.bans then return end
	local id = util.SteamIDFrom64(id64)
	local ban = maestro.bans[id]
	if ban then
		if tonumber(ban.unban) > os.time() then
			local unban = "\n(" .. maestro.time(ban.unban - os.time(), 2) .. " remaining)"
			return false, "Banned: " .. string.sub(ban.reason, 1, 255 - 8 - #unban) .. unban
		elseif ban.perma then
			return false, "Permabanned: " .. ban.reason
		end
	end
end)
