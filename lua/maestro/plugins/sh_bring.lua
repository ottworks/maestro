local function isroom(start, f, ply, caller, targets)
	local a = table.Copy(targets)
	table.insert(a, caller)
	local tr = util.TraceHull{
		start = start,
		endpos = start + f * 150,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		filter = a,
	}
	local tr2 = util.TraceHull{
		start = tr.HitPos,
		endpos = tr.HitPos,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		filter = ply,
	}
	if not tr2.Hit then
		return tr.HitPos
	else
		return false
	end
end
maestro.command("bring", {"player:target(s)"}, function(caller, targets)
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	end
	local a = caller:EyeAngles().y
	local deg = 0
	local pos = {}
	local tries = -1
	for _, ply in pairs(targets) do
		if ply == caller then continue end
		while true do
			tries = tries + 1
			if tries % 2 == 0 then
				deg = deg - tries * 18
			else
				deg = deg + tries * 18
			end
			local room = isroom(caller:GetPos(), Angle(0, a + deg, 0):Forward(), ply, caller, targets)
			if room then
				ply:SetPos(room)
				local ang = (caller:GetPos() - ply:GetPos()):Angle()
				ang.p = 0
				ang.r = 0
				ply:SetEyeAngles(ang)
				break
			end
			if tries > 50 then
				ply:SetPos(caller:GetPos())
				break
			end
		end
	end
	return false, "brought %1"
end, [[
Brings the specified player(s) to you.]])

--Algorithm: Rotate around the player from a set distance until a spot is clear. Start in front and fan outwards.
