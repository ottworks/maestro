maestro.command("ignite", {"player:target", "time:optional"}, function(caller, targets, time)
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		ply:Ignite(time)
	end
	if time then
		return false, "ignited %1 for %2"
	end
	return false, "extinguished %1"
end, [[
Lights the targeted players on fire.]])

maestro.command("extinguish", {}, function(caller)
		for _, ent in pairs( ents.GetAll() ) do
			ent:Extinguish()
		end
	return false, "extinguished %1"
end, [[
Extingushes every entity]])