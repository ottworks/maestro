local rapidfires = {}
maestro.command("rapidfire", {"player:target", "number:interval(optional)"}, function(caller, targets, interval)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		if not ply.maestro_rapidfire then
			rapidfires[ply] = interval or engine.TickInterval()
			ply.maestro_rapidfire = true
		else
			rapidfires[ply] = nil
			ply.maestro_rapidfire = false
		end
	end
	if interval then
		return false, "toggled rapidfire on %% with an interval of %%"
	end
	return false, "toggled rapidfire on %%"
end)

if SERVER then
	hook.Add("Think", "maestro_rapidfire", function()
		for ply, interval in pairs(rapidfires) do
			if not IsValid(ply) then
				rapidfires[ply] = nil
				continue
			end
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then
				wep:SetNextPrimaryFire(CurTime() + interval)
				wep:SetClip1(70)
			end
		end
	end)
end