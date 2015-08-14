local grabbed = {}
maestro.hook("PhysgunPickup", "physgunplayers", function(ply, ent)
    if ent:IsPlayer() then
        if maestro.target("$" .. ent:EntIndex(), ply, "freeze")[1] == ent then
            ent:SetMoveType(MOVETYPE_NONE)
            grabbed[ent] = ent:GetPos()
            return true
        end
    end
end)
maestro.hook("PhysgunDrop", "physgunplayers", function(ply, ent)
    if ent:IsPlayer() and SERVER then
        ent:SetMoveType(MOVETYPE_WALK)
        local cur = ent:GetPos()
        local prev = grabbed[ent]
        local vel = (cur - prev) / FrameTime()
        grabbed[ent] = nil
        ent:SetVelocity(vel)
    end
end)
maestro.hook("Think", "physgunplayers", function()
    for ply, pos in pairs(grabbed) do
        grabbed[ply] = ply:GetPos()
    end
end)
