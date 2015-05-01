maestro.command("slap", {"player", "number"}, function(caller, ply, dmg)
	if not IsValid(ply) or not ply:IsPlayer() then
		return "Invalid player!"
	end
	dmg = dmg or 0
	local info = DamageInfo()
	info:SetDamage(dmg)
	info:SetDamageType(DMG_CLUB)
	ply:TakeDamageInfo(info)
	ply:SetVelocity(Vector(math.random(-100, 100), math.random(-100, 100), math.random(250, 300)))
	ply:EmitSound("player/pl_pain7.wav", 60, math.random(90, 110))
	return "a"
end)