local rapidfires = {}
maestro.command("rapidfire", {"player:target", "boolean:toggle(optional)"}, function(caller, targets, state)
	if targets then
		if #targets == 0 then
			return true, "Query matched no players."
		end
		for _, ply in pairs(targets) do
			if state == true then
				rapidfires[ply] = true
					ply.maestro_rapidfire = true
			elseif state == false then
				rapidfires[ply] = nil
					ply.maestro_rapidfire = false
			else
				if not ply.maestro_rapidfire then
					rapidfires[ply] = true
					ply.maestro_rapidfire = true
				else
					rapidfires[ply] = nil
					ply.maestro_rapidfire = false
				end
			end
		end
		if state == nil then
			return false, "toggled rapidfire on %%"
		end
		return false, "set rapidfire on %% to %%"
	else
		rapidfires[caller] = not caller.maestro_rapidfire
		caller.maestro_rapidfire = not caller.maestro_rapidfire
		return false, "toggled rapidfire on themselves"
	end
end)

if SERVER then
	hook.Add("Think", "maestro_rapidfire", function()
		for ply in pairs(rapidfires) do
			if not IsValid(ply) then
				rapidfires[ply] = nil
				continue
			end
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then
				wep:SetNextPrimaryFire(CurTime() + engine.TickInterval())
				wep:SetClip1(70)
			end
		end
	end)
end 