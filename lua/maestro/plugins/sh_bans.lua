maestro.command("ban", {"player:target", "time", "reason"}, function(caller, targets, time, reason)
	if #targets == 0 then 
		return true, "Query matched no players."
	elseif #targets > 1 then
		return true, "Query matched more than 1 player."
	end
	local ply = targets[1]
	maestro.ban(ply, time, reason)
	return false, "banned %% for %% (%%)"
end)
maestro.command("unban", {"id", "reason"}, function(caller, id, reason)
	maestro.unban(id)
	return false, "unbanned %% (%%)"
end)