local froze = {}
maestro.command("freeze", {"player:target", "boolean:state(optional)"}, function(caller, targets, state)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            froze[ply] = not froze[ply]
            ply:Freeze(froze[ply])
            if froze[ply] then
                ply:SetMoveType(MOVETYPE_NONE)
            else
                ply:SetMoveType(MOVETYPE_WALK)
            end
        end
        return false, "toggled freeze on %1"
    else
        for i = 1, #targets do
            local ply = targets[i]
            froze[ply] = state
            ply:Freeze(froze[ply])
            if froze[ply] then
                ply:SetMoveType(MOVETYPE_NONE)
            else
                ply:SetMoveType(MOVETYPE_WALK)
            end
        end
        if state then
            return false, "froze %1"
        end
        return false, "unfroze %1"
    end
end)
maestro.hook("CanPlayerSuicide", "freeze", function(ply)
    if froze[ply] then
        maestro.chat(ply, maestro.orange, "You can't suicide right now!")
        return false
    end
end)
