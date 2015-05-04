maestro.command("noclip", {"player:target", "boolean:toggle"}, function(caller, targets, state)
	if targets then
		if state ~= nil then
			for ply in pairs(targets) do
				ply:SetMoveType(state and MOVETYPE_NOCLIP or MOVETYPE_WALK)
			end
		else
			for ply in pairs(targets) do
				ply:SetMoveType((ply:GetMoveType() == MOVETYPE_NOCLIP) and MOVETYPE_WALK or MOVETYPE_NOCLIP)
			end
		end
	else
		caller:SetMoveType((caller:GetMoveType() == MOVETYPE_NOCLIP) and MOVETYPE_WALK or MOVETYPE_NOCLIP)
	end
end)

hook.Add("PlayerNoClip", "maestro_noclip", function(ply, state)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then 
		return true 
	elseif ply:GetMoveType() == MOVETYPE_FLY then
		ply:SetMoveType(MOVETYPE_WALK)
		return false
	end
	if maestro.rankget(maestro.userrank(ply)).perms.noclip then
		return true
	end
end)