local meta = FindMetaTable("Player")
if not meta then return end

function meta:IsAdmin()
	if not maestro.rankget(self:GetUserGroup()).flags then return end
	return maestro.rankget(self:GetUserGroup()).flags.admin
end

function meta:IsSuperAdmin()
	if not maestro.rankget(self:GetUserGroup()).flags then return end
	return maestro.rankget(self:GetUserGroup()).flags.superadmin
end

function meta:IsUserGroup(name)
	return self:GetNWString("rank", "user") == name
end

function meta:GetUserGroup(name)
	return self:GetNWString("rank", "user")
end

if not SERVER then return end

function meta:SetUserGroup(name)
	if not IsValid(self) then return end
	maestro.userrank(self, name)
end

local function auth(ply, steam)
	local q = mysql:Select("maestro_users")
		q:Where("steamid", steam)
		q:Callback(function(res, status)
			if type(res) == "table" then
				maestro.users[steam] = {rank = res[1].rank}
			end
			local name = maestro.userrank(steam)
			if game.SinglePlayer() or ply:IsListenServerHost() then
				steam = ply:SteamID64() or 0
				name = "root"
				maestro.userrank(ply, "root")
			end
			if not name then
				maestro.userrank(steam, "user")
			elseif not maestro.rankget(name).flags.anonymous then
				ply:SetNWString("rank", name or "user")
			end
			maestro.sendranks(ply)
		end)
	q:Execute()
end
maestro.hook("PlayerAuthed", "maestro_PlayerAuthed", function(ply, steam)
	steam = util.SteamIDTo64(steam)
	if ply.IsFullyAuthenticated and not ply:IsFullyAuthenticated() then
		maestro.chat(ply, maestro.orange, "Hey, your SteamID isn't validated. We're going to check again in 15 seconds and then kick you if you aren't validated by then.")
		timer.Simple(15, function()
			if ply.IsFullyAuthenticated and not ply:IsFullyAuthenticated() then
				ply:Kick("SteamID not validated, try again later.")
				return
			end
			auth(ply, steam)
		end)
		return
	end
	auth(ply, steam)
end)

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") --removing vanilla stuff resetting rank
