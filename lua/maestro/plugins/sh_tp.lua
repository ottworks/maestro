maestro.command("tp", {"player:target(optional)"}, function(caller, targets)
	targets = targets or {}
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	end
	local tr = util.TraceHull{
		start = caller:GetShootPos(),
		endpos = caller:GetShootPos() + caller:EyeAngles():Forward() * 16384,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		filter = {caller, targets[1]},
	}
	if not tr.HitPos then
		return true, "No room!"
	end
	if #targets == 1 then
		targets[1]:SetPos(tr.HitPos)
		return false, "teleported %1"
	end
	caller:SetPos(tr.HitPos)
	return false, "teleported themselves"
end, [[
Teleports a player, or yourself if none is specified.]])