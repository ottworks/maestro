maestro.command("noclip", {"player:target", "boolean:toggle"}, function(caller, targets, state)
	if targets then
		if state ~= nil then
			for _, ply in pairs(targets) do
				ply:SetMoveType(state and MOVETYPE_NOCLIP or MOVETYPE_WALK)
			end
			if state then
				return false, "enabled noclip mode on %1"
			end
			return false, "disabled noclip mode on %1"
		else
			for _, ply in pairs(targets) do
				ply:SetMoveType((ply:GetMoveType() == MOVETYPE_NOCLIP) and MOVETYPE_WALK or MOVETYPE_NOCLIP)
			end
		end
		return false, "toggled noclip mode on %1"
	else
		caller:SetMoveType((caller:GetMoveType() == MOVETYPE_NOCLIP) and MOVETYPE_WALK or MOVETYPE_NOCLIP)
		return false, "toggled noclip mode on themselves"
	end
end)

hook.Add("PlayerNoClip", "maestro_noclip", function(ply, state)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then 
		return true 
	elseif ply:GetMoveType() == MOVETYPE_FLY then
		ply:SetMoveType(MOVETYPE_WALK)
		return false
	end
	if maestro.rankget(maestro.userrank(ply)) and maestro.rankget(maestro.userrank(ply)).perms.noclip then
		return true
	end
end)
