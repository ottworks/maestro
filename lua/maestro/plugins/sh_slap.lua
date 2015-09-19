local function slap(ply, dmg)
	if IsValid(ply:GetVehicle()) then
		ply:ExitVehicle()
	end
	local info = DamageInfo()
	info:SetAttacker(Entity(0))
	info:SetDamage(dmg)
	info:SetDamageType(DMG_CLUB)
	ply:TakeDamageInfo(info)
	ply:SetVelocity(Vector(math.random(-100, 100), math.random(-100, 100), math.random(250, 300)))
	ply:EmitSound("physics/body/body_medium_impact_hard6.wav", 60, math.random(90, 110))
end
maestro.command("slap", {"player:target", "number:damage(optional)", "number:times(optional)"}, function(caller, targets, dmg, times)
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	end
	for i = 1, #targets do
		local ply = targets[i]
		if not ply:Alive() then
			if #targets == 1 then
				return true, "Player is dead!"
			end
			continue
		end
		dmg = dmg or 0
		slap(ply, dmg)
		if times then
			timer.Create("maestro_slap_" .. ply:EntIndex(), 1, times - 1, function()
				if not ply:Alive() then
					timer.Remove("maestro_slap_" .. ply:EntIndex())
				end
				slap(ply, dmg)
			end)
		end
	end
	if dmg == 0 then
		if times then
			return false, "slapped %1 %3 times"
		end
		return false, "slapped %1"
	end
	if times then
		return false, "slapped %1 %3 times for %2 damage each"
	end
	return false, "slapped %1 for %2 damage"
end, [[
Slaps a player.]])
