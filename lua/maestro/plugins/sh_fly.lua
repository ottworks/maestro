 maestro.command("fly", {"player", "boolean"}, function(caller, targets, state)
 	if targets then
	 	if state ~= nil then
	 		for _, ply in pairs(targets) do
	 			ply:SetMoveType(state and MOVETYPE_FLY or MOVETYPE_WALK)
	 		end
	 	else
	 		for _, ply in pairs(targets) do
	 			ply:SetMoveType((ply:GetMoveType() == MOVETYPE_FLY) and MOVETYPE_WALK or MOVETYPE_FLY)
	 		end
	 	end
	 else
	 	caller:SetMoveType((caller:GetMoveType() == MOVETYPE_FLY) and MOVETYPE_WALK or MOVETYPE_FLY)
	 end
 end)