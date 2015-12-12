maestro.users = {}
maestro.load("users", function(val)
	maestro.users = val
end)

function maestro.userrank(id, rank, source)
	if rank then
		local ply
		if type(id) == "Player" then
			ply = id
			id = id:SteamID()
		else
			ply = player.GetBySteamID(ply)
		end
		if not id then
			return
		end
		if IsValid(ply) then
			if maestro.rankget(rank) and not maestro.rankget(rank).anonymous then
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
			end

			maestro.save("users", maestro.users)
			if source then
				CAMI.SignalUserGroupChanged(ply, old, rank, "maestro")
			end
		end
	else
		if type(id) == "Player" then
			id = id:SteamID()
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
	if source ~= "maestro" then
		maestro.userrank(ply, new, source)
	end
end)

function maestro.RESETUSERS()
	for _, ply in pairs(player.GetAll()) do
		maestro.userrank(ply, "user")
	end
	maestro.users = {}
	maestro.save("users", maestro.users)
end
