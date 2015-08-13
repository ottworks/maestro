local cloaked = {}
maestro.command("cloak", {"player:target", "boolean:state(optional)"}, function(caller, targets, state)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            cloaked[ply] = not cloaked[ply]
            ply:SetNoDraw(cloaked[ply])
        end
        return false, "toggled cloak on %1"
    else
        for i = 1, #targets do
            local ply = targets[i]
            cloaked[ply] = state
            ply:SetNoDraw(cloaked[ply])
        end
        if state then
            return false, "cloaked %1"
        end
        return false, "uncloaked %1"
    end
end, [[
Makes a player invisible.]])
