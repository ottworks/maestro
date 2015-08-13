local scaledata = {}
scaledata.jump = {}
scaledata.runspeed = {}
scaledata.crouchspeed = {}
scaledata.walkspeed = {}
scaledata.scaled = {}
local function doscale(ply, scale)
    scaledata.scaled[ply] = true
    ply:SetModelScale(scale)
    ply:SetHull(Vector(-16, -16, 0) * scale, Vector(16, 16, 72) * scale)
    ply:SetHullDuck(Vector(-16, -16, 0) * scale, Vector(16, 16, 36) * scale)
    ply:SetViewOffset(Vector(0, 0, 64 * scale))
    ply:SetViewOffsetDucked(Vector(0, 0, 28 * scale))
    ply:SetStepSize(18 * scale)
    scaledata.jump[ply] = ply:GetJumpPower()
    ply:SetJumpPower(ply:GetJumpPower() * scale^(1/3))
    scaledata.runspeed[ply] = ply:GetRunSpeed()
    ply:SetRunSpeed(ply:GetRunSpeed() * scale)
    scaledata.walkspeed[ply] = ply:GetWalkSpeed()
    ply:SetWalkSpeed(ply:GetWalkSpeed() * scale)

    local hat = ply:LookupBone("ValveBiped.Bip01_Head1")
    if hat then
        ply:ManipulateBoneScale(hat, Vector(1, 1, 1) / scale^(1/3))
    end
    ply:SetPlaybackRate(1 / scale)
end
local function unscale(ply)
    scaledata.scaled[ply] = false
    ply:SetModelScale(1)
    ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72))
    ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 36))
    ply:SetViewOffset(Vector(0, 0, 64))
    ply:SetViewOffsetDucked(Vector(0, 0, 28))
    ply:SetStepSize(18)
    if scaledata.jump[ply] then ply:SetJumpPower(scaledata.jump[ply]) end
    if scaledata.runspeed[ply] then ply:SetRunSpeed(scaledata.runspeed[ply]) end
    if scaledata.walkspeed[ply] then ply:SetWalkSpeed(scaledata.walkspeed[ply]) end

    local hat = ply:LookupBone("ValveBiped.Bip01_Head1")
    if hat then
        ply:ManipulateBoneScale(hat, Vector(1, 1, 1))
    end
    ply:SetPlaybackRate(1)
end
if SERVER then
    util.AddNetworkString("maestro_scale")
end
maestro.command("scale", {"player:target", "number:scale"}, function(caller, targets, scale)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if scale then
        scale = math.max(scale, 1/16)
        scale = math.min(scale, 16)
        for i = 1, #targets do
            unscale(targets[i])
            doscale(targets[i], scale)
        end
        net.Start("maestro_scale")
            net.WriteUInt(#targets, 8)
            for i = 1, #targets do
                net.WriteEntity(targets[i])
            end
            net.WriteFloat(scale, 4)
        net.Broadcast()
        return false, "scaled %1 by %2"
    else
        for i = 1, #targets do
            unscale(targets[i])
        end
        net.Start("maestro_scale")
            net.WriteUInt(#targets, 8)
            for i = 1, #targets do
                net.WriteEntity(targets[i])
            end
            net.WriteFloat(0)
        net.Broadcast()
        return false, "reset the scale of %1"
    end
end, [[
Scales a player between 1/16th and 16 times their size.]])
net.Receive("maestro_scale", function()
    local num = net.ReadUInt(8)
    local plys = {}
    for i = 1, num do
        plys[i] = net.ReadEntity()
    end
    local scale = net.ReadFloat()
    if scale == 0 then
        for i = 1, #plys do
            unscale(plys[i])
        end
    else
        for i = 1, #plys do
            unscale(plys[i])
            doscale(plys[i], scale)
        end
    end
end)
maestro.hook("DoPlayerDeath", "scale", function(ply)
    if scaledata.scaled[ply] then
        unscale(ply)
        net.Start("maestro_scale")
            net.WriteUInt(1, 8)
            net.WriteEntity(ply)
            net.WriteFloat(0)
        net.Broadcast()
    end
end)
