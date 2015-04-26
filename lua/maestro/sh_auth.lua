local meta = FindMetaTable("Player")
if not meta then return end

function meta:IsAdmin()
	return maestro.ranks[self:GetUserGroup()].admin
end

function meta:IsSuperAdmin()
	return maestro.ranks[self:GetUserGroup()].superadmin
end

function meta:IsUserGroup(name)
	return self:GetNWString("usergroup", "user") == name
end

function meta:GetUserGroup(name)
	return self:GetNWString("usergroup", "user")
end

if not SERVER then return end

function meta:SetUserGroup(name)
	self:SetNWString("usergroup", name)
	ply:SetPData("usergroup", name)
end

hook.Add("PlayerAuthed", "maestro_PlayerAuthed", function(ply, steam, uid)
	ply:SetNWString("usergroup", ply:GetPData("usergroup", "user"))
end)