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

maestro.hook("PlayerAuthed", "maestro_PlayerAuthed", function(ply, steam, uid)
	local name = maestro.userrank(steam)
	if game.SinglePlayer() and ply == Entity(1) then
		steam = ply:SteamID()
		name = "root"
		maestro.userrank(ply, "root")
	end
	if not name then
		maestro.userrank(steam, "user")
	elseif not maestro.rankget(name).flags.anonymous then
		ply:SetNWString("rank", name or "user")
	end
	maestro.sendranks(ply)
	print(ply:GetNWString("rank"))
end)

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") --removing vanilla stuff resetting rank
