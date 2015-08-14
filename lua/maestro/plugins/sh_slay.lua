maestro.command("slay", {"player:target", "boolean:silent(optional)"}, function(caller, targets, silent)
	if #targets == 0 then
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
		if silent then
			ply:KillSilent()
		else
			ply:Kill()
		end
	end
	if silent then
		return false, "slayed %1 silently"
	end
	return false, "slayed %1"
end, [[
Slays a player.]])
