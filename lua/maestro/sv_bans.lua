maestro.bans = {}

function maestro.ban(id, time, reason, adminid)
	local ply
	if type(id) == "Player" then
		ply = id
		id = id:SteamID64()
	end
	if player.GetBySteamID and player.GetBySteamID64(id) then
		ply = player.GetBySteamID64(id)
	end
	local admin
	if type(id) == "Player" then
		admin = adminid
		adminid = adminid:SteamID64()
	end
	if player.GetBySteamID and player.GetBySteamID64(adminid) then
		admin = player.GetBySteamID64(adminid)
	end
	if ply then
		if time == 0 then
			ply:Kick("Permabanned: " .. reason)
		else
			local unban = "\n(" .. maestro.time(time, 2) .. " remaining)"
			ply:Kick("Banned: " .. string.sub(reason, 1, 255 - 8 - #unban) .. unban)
		end
	end

	local q = mysql:Select("maestro_bans")
		q:Where("steamid", id)
		q:WhereGT("until", os.time())
		q:Where("unban", "")
		q:Callback(function(res, status, last)
			if last then
				local q = mysql:Update("maestro_bans")
					q:Update("name", ply and ply:Nick() or "")
					q:Update("when", os.time())
					q:Update("until", os.time() + time)
					q:Update("reason", reason or "")
					q:Update("admin", admin and admin:Nick() or "")
					q:Update("adminid", adminid or 0)
					q:Where("steamid", id)
					q:WhereGT("until", os.time())
					q:Where("unban", "")
				q:Execute()
			else
				local q = mysql:Insert("maestro_bans")
					q:Insert("name", ply and ply:Nick() or "")
					q:Insert("steamid", id)
					q:Insert("when", os.time())
					q:Insert("until", os.time() + time)
					q:Insert("reason", reason or "")
					q:Insert("admin", admin and admin:Nick() or "")
					q:Insert("adminid", adminid or 0)
					q:Insert("unban", "")
					q:Insert("unbanid", 0)
				q:Execute()
			end
		end)
	q:Execute()

end
function maestro.unban(id, reason, adminid)
	local q = mysql:Update("maestro_bans")
		q:Update("name", ply and ply:Nick() or "")
		q:Update("until", os.time() + time)
		q:Update("reason", reason or "")
		q:Update("admin", admin and admin:Nick() or "")
		q:Update("adminid", adminid)
		q:Where("steamid", id)
		q:WhereGT("when", os.time())
		q:WhereLT("until", os.time())
		q:Where("unban", "")
	q:Execute()
end

maestro.hook("CheckPassword", "maestro_bans", function(id64)
	if not maestro.bans then return end
	local id = util.SteamIDFrom64(id64)
	--local ban = maestro.bans[id]
	if ban then
		if tonumber(ban.unban) > os.time() then
			local unban = "\n(" .. maestro.time(ban.unban - os.time(), 2) .. " remaining)"
			return false, "Banned: " .. string.sub(ban.reason, 1, 255 - 8 - #unban) .. unban
		elseif ban.perma then
			return false, "Permabanned: " .. ban.reason
		end
	end
end)

maestro.hook("DatabaseConnected", "bans", function()
	local q = mysql:Create("maestro_bans")
		q:Create("id", "INT NOT NULL AUTO_INCREMENT")
		q:Create("name", "VARCHAR(32) NOT NULL")
		q:Create("steamid", "BIGINT NOT NULL")
		q:Create("when", "BIGINT NOT NULL")
		q:Create("until", "BIGINT NOT NULL")
		q:Create("reason", "VARCHAR(255) NOT NULL")
		q:Create("admin", "VARCHAR(32) NOT NULL")
		q:Create("adminid", "BIGINT NOT NULL")
		q:Create("unban", "VARCHAR(255) NOT NULL")
		q:Create("unbanid", "BIGINT NOT NULL")
		q:PrimaryKey("id")
	q:Execute()
end)
