maestro.users = {}

function maestro.userrank(id, rank, source)
	if rank then
		local ply
		if type(id) == "Player" then
			ply = id
			id = id:SteamID64()
		else
			ply = player.GetBySteamID64(ply)
		end
		if not id then
			return
		end
		if IsValid(ply) then
			if not maestro.rankget(rank).flags.anonymous then
				ply:SetNWString("rank", rank)
			else
				ply:SetNWString("rank", "user")
			end
		end

		if source ~= "init" then
			maestro.users[id] = maestro.users[id] or {}
			local old = maestro.users[id].rank

			maestro.users[id].rank = rank
			if rank == "user" then
				maestro.users[id] = nil
				local q = mysql:Delete("maestro_users")
					q:Where("steamid", id)
				q:Execute()
			else
				local q = mysql:Select("maestro_users")
					q:Where("steamid", id)
					q:Callback(function(res, status)
						if type(res) == "table" and #res > 0 then
							local q = mysql:Update("maestro_users")
								q:Where("steamid", id)
								q:Update("rank", rank)
							q:Execute()
						else
							local q = mysql:Insert("maestro_users")
								q:Insert("steamid", id)
								q:Insert("rank", rank)
							q:Execute()
						end
					end)
				q:Execute()
			end
			if not source then
				CAMI.SignalUserGroupChanged(ply, old, rank, "maestro")
			end
		end
	else
		if type(id) == "Player" and IsValid(id) then
			id = id:SteamID64()
		end
		if not maestro.users[id] then
			return "user"
		end
		if maestro.rankget(maestro.users[id].rank) ~= "user" then
			return maestro.users[id].rank
		end
		return "user"
	end
end
hook.Add("CAMI.PlayerUsergroupChanged", "maestro", function(ply, old, new, source)
	print("CAMI.PlayerUsergroupChanged", ply, old, new, source)
	if source ~= "maestro" then
		maestro.userrank(ply, new, source)
	end
end)

function maestro.RESETUSERS()
	for _, ply in pairs(player.GetAll()) do
		maestro.userrank(ply, "user")
	end
	maestro.users = {}
	local q = mysql:Delete("maestro_users")
	q:Execute()
end

maestro.hook("DatabaseConnected", "users", function()
	local q = mysql:Create("maestro_users")
		q:Create("id", "INT NOT NULL AUTO_INCREMENT")
        q:Create("steamid", "BIGINT NOT NULL")
        q:Create("rank", "VARCHAR(255) NOT NULL")
        q:PrimaryKey("id")
    q:Execute()

	--[[

	--]]
end)

maestro.hook("CheckPassword", function(id64)
	local q = mysql:Select("maestro_users")
		q:Where("steamid", id64)
		q:Callback(function(res, status)
			if type(res) ~= "table" then return end
			maestro.users[id64] = {rank = res[1].rank}
		end)
	q:Execute()
end)
