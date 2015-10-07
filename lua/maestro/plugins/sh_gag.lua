local gagged = {}
if SERVER then
	maestro.hook("PlayerCanHearPlayersVoice", "maestro_gag", function(listener, talker)
		return not gagged[talker] and nil
	end)
end
maestro.command("gag", {"player:target", "boolean:state(optional)"}, function(caller, targets, state)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            gagged[ply] = not gagged[ply]
        end
        return false, "toggled gag on %1"
    else
        for i = 1, #targets do
            local ply = targets[i]
            gagged[ply] = state
        end
        if state then
            return false, "gagged %1"
        end
        return false, "ungagged %1"
    end
end, [[
Disables voice chat for the target.]])
