local gagged = {}
if SERVER then
	hook.Add("PlayerCanHearPlayersVoice", "maestro_gag", function(listener, talker)
		return gagged[talker] and false
	end)
end
maestro.command("gag", {"player:target", "time:optional"}, function(caller, targets, time)
	if #targets < 1 then
		return true, "Query matched no players."
	end
	for i = 1, #targets do
		gagged[targets[i]] = true
		if time then
			timer.Create("maestro_gag_" .. targets[i]:EntIndex(), time, 1, function()
				gagged[targets[i]] = nil
			end)
		end
	end
	if time then
		return false, "gagged %1 for %2"
	end
	return false, "gagged %1"
end, [[
Prevents the targetted players from using voice chat for an optional amount of time.]])
maestro.command("ungag", {"player:target"}, function(caller, targets, time)
	if #targets < 1 then
		return true, "Query matched no players."
	end
	for i = 1, #targets do
		gagged[targets[i]] = nil
		timer.Remove("maestro_gag_" .. targets[i]:EntIndex())
	end
	return false, "ungagged %1"
end, [[
Re-enables the targetted players' voice chats.]])