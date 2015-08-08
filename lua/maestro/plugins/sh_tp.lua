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
		targets[1].maestro_return = targets[1]:GetPos()
		targets[1]:SetPos(tr.HitPos)
		return false, "teleported %1"
	end
	caller.maestro_return = caller:GetPos()
	caller:SetPos(tr.HitPos)
	return false, "teleported themselves"
end, [[
Teleports a player, or yourself if none is specified.]])
maestro.command("goto", {"player:target"}, function(caller, targets)
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	elseif not targets or #targets == 0 then
		return true, "Query matched no players."
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
		filter = {ply, caller},
	}
	if tr.Hit then
		local tr2 = util.TraceHull{
			start = tr.HitPos + Vector(0, 0, 1),
			endpos = tr.HitPos + Vector(0, 0, 1),
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72),
			filter = caller,
		}
		if not tr2.Hit then
			caller.maestro_return = caller:GetPos()
			caller:SetPos(tr.HitPos + Vector(0, 0, 1))
			caller:SetEyeAngles(a)
		elseif caller:GetMoveType() == MOVETYPE_NOCLIP then
			caller.maestro_return = caller:GetPos()
			caller:SetPos(ply:GetPos())
			caller:SetEyeAngles(a)
		else
			return true, "No room to teleport! Enter noclip to override."
		end
	else
		caller.maestro_return = caller:GetPos()
		caller:SetPos(ply:GetPos() - f * 150)
		caller:SetEyeAngles(a)
	end
	return false, "teleported to %1"
end, [[
Teleports you behind the specified player.]])
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
				ply.maestro_return = ply:GetPos()
				ply:SetPos(room)
				local ang = (caller:GetPos() - ply:GetPos()):Angle()
				ang.p = 0
				ang.r = 0
				ply:SetEyeAngles(ang)
				break
			end
			if tries > 50 then
				ply.maestro_return = ply:GetPos()
				ply:SetPos(caller:GetPos())
				break
			end
		end
	end
	return false, "brought %1"
end, [[
Brings the specified player(s) to you.]])

--Algorithm: Rotate around the player from a set distance until a spot is clear. Start in front and fan outwards.
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
				ply.maestro_return = ply:GetPos()
				ply:SetPos(room)
				local ang = (tgt:GetPos() - ply:GetPos()):Angle()
				ang.p = 0
				ang.r = 0
				ply:SetEyeAngles(ang)
				break
			end
			if tries > 50 then
				ply.maestro_return = ply:GetPos()
				ply:SetPos(tgt:GetPos())
				break
			end
		end
	end
	return false, "sent %1 to %2"
end, [[
Sends the first group of players to the second player.]])
maestro.command("return", {"player:target(optional)"}, function(caller, targets)
	if targets and #targets > 0 then
		local done = false
		for i = 1, #targets do
			if targets[i].maestro_return then
				targets[i]:SetPos(targets[i].maestro_return)
				targets[i].maestro_return = nil
				done = true
			end
		end
		if not done then
			return true, "No return points found!"
		elseif #targets > 1 then
			return false, "returned %1 to their previous positions"
		else
			return false, "returned %1 to their previous position"
		end
	elseif caller.maestro_return then
		caller:SetPos(caller.maestro_return)
		caller.maestro_return = nil
		return false, "returned themselves to their previous position"
	else
		return true, "No return points found!"
	end
end, [[
Returns the targets to their positions before any teleport commands.]])
