maestro.bans = {}

function maestro.ban(id, time, reason, adminid)
	local ply
	if type(id) == "Player" then
		ply = id
		id = id:SteamID64() or 0
	end
	if player.GetBySteamID and player.GetBySteamID64(id) or 0 then
		ply = player.GetBySteamID64(id) or 0
	end
	local admin
	if type(id) == "Player" then
		admin = adminid
		adminid = adminid:SteamID64() or 0
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

	local q = mysql:Select(maestro.config.tables.bans)
		q:Where("steamid", id)
		q:WhereGT("until", os.time())
		q:Where("unban", "")
		q:Callback(function(res, status)
			if type(res) == "table" and #res > 0 then
				local q = mysql:Update(maestro.config.tables.bans)
					q:Update("name", ply and ply:Nick() or "")
					q:Update("when", os.time())
					q:Update("until", time == 0 and time or (os.time() + time))
					q:Update("reason", reason or "")
					q:Update("admin", admin and admin:Nick() or "")
					q:Update("adminid", adminid or 0)
					q:Where("steamid", id)
					q:WhereGT("until", os.time())
					q:Where("unban", "")
				q:Execute()
			else
				local q = mysql:Insert(maestro.config.tables.bans)
					q:Insert("name", ply and ply:Nick() or "")
					q:Insert("steamid", id)
					q:Insert("when", os.time())
					q:Insert("until", time == 0 and time or (os.time() + time))
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
	local q = mysql:Update(maestro.config.tables.bans)
		q:Update("unbanid", adminid or 0)
		q:Update("unban", reason)
		q:Where("steamid", id)
		q:WhereGT("until", os.time())
		q:Where("unban", "")
	q:Execute()
	local q = mysql:Update(maestro.config.tables.bans)
		q:Update("unbanid", adminid or 0)
		q:Update("unban", reason)
		q:Where("steamid", id)
		q:Where("until", 0)
		q:Where("unban", "")
	q:Execute()
end

maestro.hook("CheckPassword", "bans", function(id64)
	print(id64)
	local id = util.SteamIDFrom64(id64)
	print(id)
	local q = mysql:Select(maestro.config.tables.bans)
		q:Where("steamid", id64)
		q:Where("unban", "")
		q:WhereGT("until", os.time())
		q:Callback(function(res, status, last)
			if type(res) == "table" and #res > 0 then
				local last = res[1]
				local unban = " (" .. maestro.time(last["until"] - os.time(), 2) .. " remaining)"
				game.ConsoleCommand("kickid " .. id .. " Banned: " .. string.sub(last.reason:gsub(";", ":"), 1, 255 - 8 - #unban) .. unban .. "\n")
			end
		end)
	q:Execute()
	local q = mysql:Select(maestro.config.tables.bans)
		q:Where("steamid", id64)
		q:Where("unban", "")
		q:Where("until", 0)
		q:Callback(function(res, status)
			if type(res) == "table" and #res > 0 then
				local last = res[1]
				local unban = "\n(" .. maestro.time(last["until"] - os.time(), 2) .. " remaining)"
				game.ConsoleCommand("kickid " .. id .. " Permabanned: " .. last.reason:gsub(";", ":") .. "\n")
			end
		end)
	q:Execute()
end)

maestro.hook("DatabaseConnected", "bans", function()
	local q = mysql:Create(maestro.config.tables.bans)
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
