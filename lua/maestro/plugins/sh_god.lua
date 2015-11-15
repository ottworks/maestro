maestro.command("god", {"player:target(optional)", "boolean:state(optional)"}, function(caller, targets, state)
	if not targets then
		if not caller then return true, "Command cannot be run from the server console." end
		if caller:HasGodMode() then
			caller:GodDisable()
		else
			caller:GodEnable()
		end
		return false, "toggled god mode on themselves"
	end
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		if state == nil then
			if ply:HasGodMode() then
				ply:GodDisable()
			else
				ply:GodEnable()
			end
		elseif state then
			ply:GodEnable()
		else
			ply:GodDisable()
		end
	end
	if state == nil then
		return false, "toggled god mode on %1"
	end
	if state then
		return false, "enabled god mode on %1"
	end
	return false, "disabled god mode on %1"
end, [[
Makes a player invincible.
If no player(s) are specified, it will toggle god mode on you.
If player(s) are specified but no boolean is specified, it will toggle god mode on the players.
If both player(s) and boolean are specified, it will set god mode on the players to the boolean's value.]])
