local specs = {}
maestro.command("spectate", {"player:target(optional)"}, function(caller, targets)
    if targets then
        if #targets == 0 then
            return true, "Query matched no players."
        elseif #targets > 1 then
            return true, "Query matched more than one player."
        end
        specs[caller] = targets[1]
        caller:SpectateEntity(targets[1])
        caller:Spectate(OBS_MODE_IN_EYE)
        maestro.commands.strip.callback(ply, {ply}, true)
        return false, "started spectating %1"
    else
        caller:UnSpectate()
        local pos = caller:GetPos()
        caller:Spawn()
        caller:SetPos(pos)
        maestro.commands.strip.callback(ply, {ply}, false)
        specs[caller] = nil
        return false, "stopped spectating"
    end
end, [[
Spectates a player. Call with no arguments to unspectate.]])
maestro.hook("SetupPlayerVisibility", "spectate", function(ply)
    if specs[ply] then
        AddOriginToPVS(specs[ply]:EyePos())
    end
end)
