maestro.command("kick", {"player:target", "string:reason"}, function(caller, targets, reason)
	if not IsValid(targets[1]) then
		return true, "Query matched no players."
	end
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	end
	targets[1]:Kick(reason)
	return false, "kicked %% (%%)"
end)