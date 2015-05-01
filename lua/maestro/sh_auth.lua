local meta = FindMetaTable("Player")
if not meta then return end

function meta:IsAdmin()
	return maestro.rank(self:GetUserGroup()).admin
end

function meta:IsSuperAdmin()
	return maestro.rank(self:GetUserGroup()).superadmin
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
	maestro.setrank(self, name)
end

hook.Add("PlayerAuthed", "maestro_PlayerAuthed", function(ply, steam, uid)
	local name = maestro.getrank(steam)
	if maestro.rank(name).visisble then
		ply:SetNWString("rank", name)
	end
	maestro.sendranks(ply)
end)