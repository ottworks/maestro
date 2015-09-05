maestro.command("cleanup", {"player:target"}, function(caller, targets)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	
	for _, ply in pairs(targets) do
	ply:ConCommand( "gmod_cleanup" )
	end

	return false, "cleaned up the entities of %1"
end, [[
Cleanup the entities of the map.]])
