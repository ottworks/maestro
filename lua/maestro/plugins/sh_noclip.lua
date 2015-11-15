maestro.command("noclip", {"player:target(optional)", "boolean:state(optional)"}, function(caller, targets, state)
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
		if not caller then return true, "Command cannot be run from the server console." end
		caller:SetMoveType((caller:GetMoveType() == MOVETYPE_NOCLIP) and MOVETYPE_WALK or MOVETYPE_NOCLIP)
		return false, "toggled noclip mode on themselves"
	end
end, [[
Makes a player noclip.
If no player(s) are specified, it will toggle noclip mode on you.
If player(s) are specified but no boolean is specified, it will toggle noclip mode on the players.
If both player(s) and boolean are specified, it will set noclip mode on the players to the boolean's value.]])

maestro.hook("PlayerNoClip", "maestro_noclip", function(ply, state)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then
		return true
	elseif ply:GetMoveType() == MOVETYPE_FLY then
		ply:SetMoveType(MOVETYPE_WALK)
		return false
	end
	local r = maestro.rankget(maestro.userrank(ply))
	if r and r.perms and r.perms.noclip then
		return true
	end
end)
