local blinded = {}
maestro.command("blind", {"player:target", "boolean:state(optional)"}, function(caller, targets, state)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            blinded[ply] = not blinded[ply]
            net.Start("maestro_blind")
                net.WriteBool(blinded[ply])
            net.Send(ply)
        end
        return false, "toggled blind on %1"
    else
        for i = 1, #targets do
            local ply = targets[i]
            blinded[ply] = state
            net.Start("maestro_blind")
                net.WriteBool(blinded[ply])
            net.Send(ply)
        end
        if state then
            return false, "blinded %1"
        end
        return false, "unblinded %1"
    end
end, [[
Blinds a player.]])
if SERVER then
    util.AddNetworkString("maestro_blind")
end
if not CLIENT then return end
local frame
net.Receive("maestro_blind", function()
    local state = net.ReadBool()
    if frame then
        frame:Remove()
    end
    if state then
        frame = vgui.Create("DPanel")
        frame:Dock(FILL)
    end
end)
