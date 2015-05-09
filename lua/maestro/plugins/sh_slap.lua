maestro.command("slap", {"player:target", "number:force"}, function(caller, targets, dmg)
	if #targets == 0 then
		return "Query matched no players."
	end
	for i = 1, #targets do
		local ply = targets[i]
		if not ply:Alive() then
			if #targets == 1 then
				return "Player is dead!"
			end
			continue
		end
		dmg = dmg or 0
		local info = DamageInfo()
		info:SetDamage(dmg)
		info:SetDamageType(DMG_CLUB)
		ply:TakeDamageInfo(info)
		ply:SetVelocity(Vector(math.random(-100, 100), math.random(-100, 100), math.random(250, 300)))
		ply:EmitSound("player/pl_pain7.wav", 60, math.random(90, 110))
	end
end)