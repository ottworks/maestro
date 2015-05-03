maestro.command("noclip", {"player", "boolean"}, function(caller, ply, state)
	ply:SetMoveType(state and MOVETYPE_NOCLIP or MOVETYPE_WALK)
end)

hook.Add("PlayerNoClip", "maestro_noclip", function(ply, state)
	if not state then return true end
	if maestro.rankget(maestro.userrank(ply)).perms.noclip then
		return true
	end
end)