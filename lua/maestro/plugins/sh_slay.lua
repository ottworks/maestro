maestro.command("slap", {"player", "number"}, function(ply, dmg)
	ply:TakeDamage(dmg) 
	return "a"
end)