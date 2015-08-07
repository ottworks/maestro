local function isroom(start, f, ply, tgt, targets)
	local a = table.Copy(targets)
	table.insert(a, tgt)
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
maestro.command("send", {"player:target", "player:to"}, function(caller, t1, t2)
	if #t1 < 1 then
		return true, "Query #1 matched no players."
	elseif #t2 > 1 then
		return true, "Query #2 matched more than 1 player."
	elseif #t2 < 1 then
		return true, "Query #2 matched no players."
	end
	local tgt = t2[1]
	local a = tgt:EyeAngles().y
	local deg = 0
	local pos = {}
	local tries = -1
	for _, ply in pairs(t1) do
		if ply == tgt then continue end
		while true do
			tries = tries + 1
			if tries % 2 == 0 then
				deg = deg - tries * 18
			else
				deg = deg + tries * 18
			end
			local room = isroom(tgt:GetPos(), Angle(0, a + deg, 0):Forward(), ply, tgt, t1)
			if room then
				ply:SetPos(room)
				local ang = (tgt:GetPos() - ply:GetPos()):Angle()
				ang.p = 0
				ang.r = 0
				ply:SetEyeAngles(ang)
				break
			end
			if tries > 50 then
				ply:SetPos(tgt:GetPos())
				break
			end
		end
	end
	return false, "sent %1 to %2"
end, [[
Sends the first group of players to the second player.]])
