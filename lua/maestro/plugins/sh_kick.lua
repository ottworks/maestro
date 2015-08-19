maestro.command("kick", {"player:target", "reason:optional"}, function(caller, targets, reason)
	if not IsValid(targets[1]) then
		return true, "Query matched no players."
	end
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	end
	targets[1]:Kick(reason)
	if reason then
		return false, "kicked %1 (%2)"
	end
	return false, "kicked %1"
end, [[
Kicks the targeted player.]])
