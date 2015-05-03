maestro.command("kick", {"player", "reason"}, function(caller, ply, reason)
	if not IsValid(ply) then
		return "Invalid player!"
	end
	ply:Kick(reason)
end)