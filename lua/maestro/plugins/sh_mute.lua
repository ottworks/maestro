local muted = {}
maestro.command("mute", {"player:target", "boolean:state(optional)"}, function(caller, targets, state)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            muted[ply] = not muted[ply]
        end
        return false, "toggled mute on %1"
    else
        for i = 1, #targets do
            local ply = targets[i]
            muted[ply] = state
        end
        if state then
            return false, "muted %1"
        end
        return false, "unmuted %1"
    end
end)
maestro.hook("PlayerSay", "maestro_mute", function(ply)
    if muted[ply] then
        return ""
    end
end)
