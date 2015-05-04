maestro.command("kick", {"player:target", "string:reason"}, function(caller, targets, reason)
	if not IsValid(targets[1]) then
		return "Invalid player!"
	end
	if #targets > 1 then
		return "You can only kick 1 player at a time!"
	end
	targets[1]:Kick(reason)
end)