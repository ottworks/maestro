maestro.command("goto", {"player:target"}, function(caller, targets)
	if #targets > 1 then
		return "Query matched more than 1 player."
	elseif #targets == 0 then
		return "Query matched no players."
	end
	local ply = targets[1]
	local a = ply:EyeAngles()
	a.p = 0
	a.r = 0
	local f = a:Forward()
	local tr = util.TraceHull{
		start = ply:GetPos(),
		endpos = ply:GetPos() - f * 150,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		filter = ply,
	}
	if tr.Hit then
		local tr2 = util.TraceHull{
			start = tr.HitPos + Vector(0, 0, 1),
			endpos = tr.HitPos + Vector(0, 0, 1),
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72),
		}
		if not tr2.Hit then
			caller:SetPos(tr.HitPos + Vector(0, 0, 1))
			caller:SetEyeAngles(a)
		elseif caller:GetMoveType() == MOVETYPE_NOCLIP then
			caller:SetPos(ply:GetPos())
			caller:SetEyeAngles(a)
		else
			return "No room to teleport! Enter noclip to override."
		end
	else
		caller:SetPos(ply:GetPos() - f * 150)
		caller:SetEyeAngles(a)
	end
end)