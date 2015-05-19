maestro.users = {}
maestro.users = maestro.load("users")

function maestro.userrank(id, rank)
	if rank then
		local ply
		if type(id) == "Player" then
			ply = id
			id = id:SteamID()
		else
			ply = player.GetBySteamID()
		end
		if not id then
			return
		end
		if IsValid(ply) then
			if not maestro.rankget(rank).undercover then
				ply:SetNWString("rank", rank)
			else
				ply:SetNWString("rank", "user")
			end
		end
		maestro.users[id] = maestro.users[id] or {}
		maestro.users[id].rank = rank
		if rank == "user" then
			maestro.users[id] = nil
		end
		maestro.save("users", maestro.users)
	else
		if type(id) == "Player" then
			id = id:SteamID()
		end
		if not maestro.users[id] then
			return "user"
		end
		return maestro.users[id].rank or "user"
	end
end

function maestro.RESETUSERS()
	for _, ply in pairs(player.GetAll()) do
		maestro.userrank(ply, "user")
	end
	maestro.users = {}
	maestro.save("users", maestro.users)
end