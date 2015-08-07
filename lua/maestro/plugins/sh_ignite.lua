maestro.command("ignite", {"player:target", "number:time"}, function(caller, targets, time)
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		ply:Ignite(time)
	end
	if time then
		return false, "ignited %1 for %2 seconds"
	end
	return false, "ignited %1"
end, [[
Lights the targeted players on fire.]])
