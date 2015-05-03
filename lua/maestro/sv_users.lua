maestro.users = {}

if not file.Exists("maestro", "DATA") then
	file.CreateDir("maestro")
end
if not file.Exists("maestro/users.txt", "DATA") then
	file.Write("maestro/users.txt", "")
end
maestro.users = util.JSONToTable(file.Read("maestro/users.txt")) or {}

function maestro.saveusers()
	file.Write("maestro/users.txt", util.TableToJSON(maestro.users))
end

function maestro.userrank(id, rank)
	if rank then
		local ply
		if type(id) == "Player" then
			ply = id
			id = id:SteamID()
		else
			ply = player.GetBySteamID()
		end
		if IsValid(ply) then
			if not maestro.rankget(rank).undercover then
				ply:SetNWString("rank", rank)
			end
		end
		maestro.users[id] = {rank = rank}
		maestro.saveusers()
	else
		if type(id) == "Player" then
			id = id:SteamID()
		end
		return maestro.users[id].rank or "user"
	end
end