maestro.command("cleanup", {"player:target"}, function(caller, targets)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	
	for _, ply in pairs(targets) do
		ply:ConCommand("gmod_cleanup")
	end

	return false, "cleaned up the props of %1"
end, [[
Cleanup the props/entities of players.]])
--Plugin by FluffyXVI