maestro.command("fly", {"player:target(optional)", "boolean:state(optional)"}, function(caller, targets, state)
	if targets then
		if state ~= nil then
			for _, ply in pairs(targets) do
				ply:SetMoveType(state and MOVETYPE_FLY or MOVETYPE_WALK)
			end
			if state then
				return false, "enabled fly mode on %1"
			end
			return false, "disabled fly mode on %1"
		else
			for _, ply in pairs(targets) do
				ply:SetMoveType((ply:GetMoveType() == MOVETYPE_FLY) and MOVETYPE_WALK or MOVETYPE_FLY)
			end
			return false, "toggled fly mode on %1"
		end
	else
		caller:SetMoveType((caller:GetMoveType() == MOVETYPE_FLY) and MOVETYPE_WALK or MOVETYPE_FLY)
		return false, "toggled fly mode on themselves"
	end
end, [[
Makes a player fly.
If no player(s) are specified, it will toggle fly mode on you.
If player(s) are specified but no boolean is specified, it will toggle fly mode on the players.
If both player(s) and boolean are specified, it will set fly mode on the players to the boolean's value.]])