local jailed = {}
local jails = {}
local function dojail(ply, state)
    if state then
        local p1 = ents.Create("prop_physics")
        p1:SetModel("models/props_phx/construct/glass/glass_angle360.mdl")
        p1:Spawn()
        p1:SetPos(ply:GetPos())
        p1:SetMoveType(MOVETYPE_NONE)
        p1:SetHealth(2^31-1)
        local p2 = ents.Create("prop_physics")
        p2:SetModel("models/props_phx/construct/glass/glass_curve360x2.mdl")
        p2:Spawn()
        p2:SetPos(ply:GetPos())
        p2:SetMoveType(MOVETYPE_NONE)
        p2:SetHealth(2^31-1)
        local p3 = ents.Create("prop_physics")
        p3:SetModel("models/props_phx/construct/glass/glass_angle360.mdl")
        p3:Spawn()
        p3:SetPos(ply:GetPos() + Vector(0, 0, 93))
        p3:SetMoveType(MOVETYPE_NONE)
        p3:SetHealth(2^31-1)

        local ct = function() return false end
        p1.CanTool = ct
        p2.CanTool = ct
        p3.CanTool = ct

        jails[ply] = {p1, p2, p3}
        ply:SetPos(ply:GetPos() + Vector(0, 0, 4))
    elseif jails[ply] then
        for i = 1, #jails[ply] do
            if IsValid(jails[ply][i]) then
                jails[ply][i]:Remove()
            end
        end
    end
end
maestro.command("jail", {"player:target", "boolean:state(optional)", "time:optional"}, function(caller, targets, state, time)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than 1 player."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            jailed[ply] = not jailed[ply]
            dojail(ply, jailed[ply])
        end
        return false, "toggled jail on %1"
    else
        for i = 1, #targets do
            local ply = targets[i]
            jailed[ply] = state
            dojail(ply, jailed[ply])
            if state and time then
                timer.Create("jailtimer_" .. ply:EntIndex(), time, 1, function()
                    if IsValid(ply) then
                        if jailed[ply] then
                            jailed[ply] = false
                            dojail(ply, false)
                        end
                    end
                end)
            end
        end
        if state then
            if time then
                return false, "jailed %1 for %3"
            end
            return false, "jailed %1"
        end
        return false, "unjailed %1"
    end
    local ply = targets[1]
end, [[
Jails a player for an optional amount of time.]])
maestro.hook("Think", "jail", function()
    for ply, state in pairs(jailed) do
        if IsValid(ply) then
            if state then
                local base = jails[ply][1]
                if IsValid(base) then
                    local dist = base:GetPos() - ply:GetPos()
                    local distz = base:GetPos() - ply:GetPos()
                    distz.x = 0
                    distz.y = 0
                    dist.z = 0
                    if dist:Length() > 32 or distz.z < -94 or distz.z > 5 then
                        ply:SetPos(base:GetPos() + Vector(0, 0, 4))
                    end
                end
            end
        else
            jailed[ply] = nil
        end
    end
end)
maestro.command("jailtp", {"player:target", "time:optional"}, function(caller, targets, time)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than 1 player."
    end
    maestro.commands.tp.callback(caller, targets)
    maestro.commands.jail.callback(caller, targets, true, time)
    if time then
        return false, "teleported and jailed %1 for %2"
    end
    return false, "teleported and jailed %1"
end, [[
Teleports and jails a player.]])
