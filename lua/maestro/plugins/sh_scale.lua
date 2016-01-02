local scaledata = {}
scaledata.jump = {}
scaledata.runspeed = {}
scaledata.crouchspeed = {}
scaledata.walkspeed = {}
scaledata.scaled = {}
scaledata.gravity = {}
local function doscale(ply, scale)
    scaledata.scaled[ply] = scale
    ply:SetModelScale(scale)
    ply:SetHull(Vector(-16, -16, 0) * scale, Vector(16, 16, 72) * scale)
    ply:SetHullDuck(Vector(-16, -16, 0) * scale, Vector(16, 16, 36) * scale)
    ply:SetViewOffset(Vector(0, 0, 64 * scale))
    ply:SetViewOffsetDucked(Vector(0, 0, 28 * scale))
    ply:SetStepSize(18 * scale)
    scaledata.jump[ply] = ply:GetJumpPower()
    ply:SetJumpPower(ply:GetJumpPower() * scale^(1/4))
    scaledata.runspeed[ply] = ply:GetRunSpeed()
    ply:SetRunSpeed(ply:GetRunSpeed() * scale)
    scaledata.walkspeed[ply] = ply:GetWalkSpeed()
    ply:SetWalkSpeed(ply:GetWalkSpeed() * scale)
    scaledata.gravity[ply] = ply:GetGravity()
    ply:SetGravity(scale^(1/4))

    if scale < 0.18 then
        ply:SetCrouchedWalkSpeed(0.82)
    end

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
    if scaledata.gravity[ply] then ply:SetGravity(scaledata.gravity[ply]) end

    ply:SetCrouchedWalkSpeed(0.3)

    local hat = ply:LookupBone("ValveBiped.Bip01_Head1")
    if hat then
        ply:ManipulateBoneScale(hat, Vector(1, 1, 1))
    end
    ply:SetPlaybackRate(1)
end
if SERVER then
    util.AddNetworkString("maestro_scale")
end
maestro.command("scale", {"player:target", "number:scale(optional)"}, function(caller, targets, scale)
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
if CLIENT then
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
end
maestro.hook("PlayerSpawn", "scale", function(ply)
    if scaledata.scaled[ply] then
        unscale(ply)
        net.Start("maestro_scale")
            net.WriteUInt(1, 8)
            net.WriteEntity(ply)
            net.WriteFloat(0)
        net.Broadcast()
    end
end)
maestro.hook("EntityTakeDamage", "scale", function(ply, info)
    if ply:IsPlayer() and scaledata.scaled[ply] then
        info:ScaleDamage(1/scaledata.scaled[ply])
    end
end)
maestro.hook("EntityEmitSound", "scale", function(info)
    local ply = info.Entity
    if IsValid(ply) and ply:IsPlayer() then
        if scaledata.scaled[ply] then
            info.Pitch = math.Clamp(info.Pitch / scaledata.scaled[ply]^(1/3), 0, 255)
            return true
        end
    end
end)
maestro.hook("UpdateAnimation", "scale", function(ply, velocity, maxseqgroundspeed)
    if scaledata.scaled[ply] then
        local len = velocity:Length() / scaledata.scaled[ply]
    	local movement = 1.0

    	if ( len > 0.2 ) then
    		movement = ( len / maxseqgroundspeed )
    	end

    	local rate = math.min( movement, 2 )

    	-- if we're under water we want to constantly be swimming..
    	if ( ply:WaterLevel() >= 2 ) then
    		rate = math.max( rate, 0.5 )
    	elseif ( !ply:IsOnGround() && len >= 1000 ) then
    		rate = 0.1
    	end

    	ply:SetPlaybackRate( rate )

    	if ( ply:InVehicle() ) then

    		local Vehicle = ply:GetVehicle()

    		-- We only need to do this clientside..
    		if ( CLIENT ) then
    			--
    			-- This is used for the 'rollercoaster' arms
    			--
    			local Velocity = Vehicle:GetVelocity()
    			local fwd = Vehicle:GetUp()
    			local dp = fwd:Dot( Vector( 0, 0, 1 ) )
    			local dp2 = fwd:Dot( Velocity )

    			ply:SetPoseParameter( "vertical_velocity", ( dp < 0 and dp or 0 ) + dp2 * 0.005 )

    			-- Pass the vehicles steer param down to the player
    			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
    			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
    			if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then steer = 0 ply:SetPoseParameter( "aim_yaw", math.NormalizeAngle( ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) ) end
    			ply:SetPoseParameter( "vehicle_steer", steer )

    		end

    	end

    	if ( CLIENT ) then
    		GAMEMODE:GrabEarAnimation( ply )
    		GAMEMODE:MouthMoveAnimation( ply )
    	end
        return true
    end
end)
maestro.hook("UpdatePlayerSpeed", "scale", function(ply)
    if not ply:Alive() then return end
    local scale = scaledata.scaled[ply]
    if scale then
        unscale(ply)
        doscale(ply, scale)
        return true
    end
end)

if not CLIENT then return end
maestro.hook("CalcView", "scale_nearz", function(ply, pos, angles, fov, nearz, farz)
    if not scaledata.scaled[ply] then return end
    if not IsValid(GetViewEntity()) or GetViewEntity() == ply then
        local view = {}
        view.znear = nearz * scaledata.scaled[ply]
        return view
    end
end)
