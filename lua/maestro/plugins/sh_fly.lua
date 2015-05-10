 maestro.command("fly", {"player:target", "boolean:toggle"}, function(caller, targets, state)
 	if targets then
	 	if state ~= nil then
	 		for _, ply in pairs(targets) do
	 			ply:SetMoveType(state and MOVETYPE_FLY or MOVETYPE_WALK)
	 		end
	 		return false, "set fly mode on %% to %%"
	 	else
	 		for _, ply in pairs(targets) do
	 			ply:SetMoveType((ply:GetMoveType() == MOVETYPE_FLY) and MOVETYPE_WALK or MOVETYPE_FLY)
	 		end
	 		return false, "toggled fly mode on %%"
	 	end
	else
	 	caller:SetMoveType((caller:GetMoveType() == MOVETYPE_FLY) and MOVETYPE_WALK or MOVETYPE_FLY)
	 	return false, "toggled fly mode on theirself"
	end
 end)