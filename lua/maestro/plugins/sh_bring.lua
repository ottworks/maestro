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
	if #targets == 0 then
		return true, "Query matched no players."
	end
	local a = caller:EyeAngles().y
	local deg = 0
	local pos = {}
	local tries = -1
	for i = 1, #targets do
		while true do
			tries = tries + 1
			if tries % 2 == 0 then
				deg = deg - tries * 18
			else
				deg = deg + tries * 18
			end
			local room = isroom(caller:GetPos(), Angle(0, a + deg, 0):Forward(), targets[i], caller, targets)
			if room then
				targets[i]:SetPos(room)
				local ang = (caller:GetPos() - targets[i]:GetPos()):Angle()
				ang.p = 0
				ang.r = 0
				targets[i]:SetEyeAngles(ang)
				break
			end
			if tries > 50 then
				targets[i]:SetPos(caller:GetPos())
				break
			end
		end
	end
	return false, "brought %%"
end)

--Algorithm: Rotate around the player from a set distance until a spot is clear. Start in front and fan outwards.