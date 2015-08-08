maestro.command("ragdoll", {"player:target", "boolean:state(optional)", "time:optional"}, function(caller, targets, state, time)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            if not ply.maestro_ragdoll then
                local ragdoll = ents.Create("prop_ragdoll")
                local data = duplicator.CopyEntTable(ply)
                ragdoll.maestro_player = ply
                ply.maestro_ragdoll = ragdoll
                duplicator.DoGeneric(ragdoll, data)
                ragdoll:Spawn()
                local vel = ply:GetVelocity()
                local objs = ragdoll:GetPhysicsObjectCount()
            	for b = 0, objs-1 do
            		local phys = ragdoll:GetPhysicsObjectNum(b)
            		if IsValid(phys) then
            			local pos, ang = ply:GetBonePosition(ply:TranslatePhysBoneToBone(b))
            			phys:SetPos(pos)
                        phys:SetAngles(ang)
            			phys:AddVelocity(vel)
            		end
            	end
                ply:Spectate(OBS_MODE_CHASE)
                ply:SpectateEntity(ragdoll)
                maestro.commands.strip.callback(ply, {ply}, true) --cheeky code re-use
            else
                local ragdoll = ply.maestro_ragdoll
                ply.maestro_ragdoll = nil
                ply:SetParent()
                local ang = ply:EyeAngles()
                ply:Spawn()
                ply:SetEyeAngles(ang)
                ply:SetPos(ragdoll:GetPos() + Vector(0, 0, 15))
                ragdoll:Remove()
                ply:UnSpectate()
                maestro.commands.strip.callback(ply, {ply}, false)
            end
        end
        return false, "toggled ragdoll on %1"
    elseif state then
        for i = 1, #targets do
            local ply = targets[i]
            if not ply.maestro_ragdoll then
                local ragdoll = ents.Create("prop_ragdoll")
                local data = duplicator.CopyEntTable(ply)
                ragdoll.maestro_player = ply
                ply.maestro_ragdoll = ragdoll
                duplicator.DoGeneric(ragdoll, data)
                ragdoll:Spawn()
                local vel = ply:GetVelocity()
                local objs = ragdoll:GetPhysicsObjectCount()
            	for b = 0, objs-1 do
            		local phys = ragdoll:GetPhysicsObjectNum(b)
            		if IsValid(phys) then
            			local pos, ang = ply:GetBonePosition(ply:TranslatePhysBoneToBone(b))
            			phys:SetPos(pos)
                        phys:SetAngles(ang)
            			phys:AddVelocity(vel)
            		end
            	end
                ply:Spectate(OBS_MODE_CHASE)
                ply:SpectateEntity(ragdoll)
                maestro.commands.strip.callback(ply, {ply}, true) --cheeky code re-use
                if tonumber(time) then
                    if time ~= 0 then
                        timer.Simple(time, function()
                            maestro.commands.ragdoll.callback(caller, {ply}, false)
                        end)
                    else
                        timer.Create("maestro_ragdoll_" .. ply:EntIndex(), 1, 0, function()
                            if ragdoll:GetVelocity():Length() < 10 then
                                maestro.commands.ragdoll.callback(caller, {ply}, false)
                                timer.Remove("maestro_ragdoll_" .. ply:EntIndex())
                            end
                        end)
                    end
                end
            end
        end
        if time and time ~= 0 then
            return false, "ragdolled %1 for %3"
        elseif time then
            return false, "soft ragdolled %1"
        else
            return false, "ragdolled %1"
        end
    else
        for i = 1, #targets do
            local ply = targets[i]
            if ply.maestro_ragdoll then
                local ragdoll = ply.maestro_ragdoll
                ply.maestro_ragdoll = nil
                ply:SetParent()
                local ang = ply:EyeAngles()
                ply:Spawn()
                ply:SetEyeAngles(ang)
                ply:SetPos(ragdoll:GetPos() + Vector(0, 0, 15))
                ragdoll:Remove()
                ply:UnSpectate()
                maestro.commands.strip.callback(ply, {ply}, false)
            end
        end
        return false, "unragdolled %1"
    end
end, [[
Ragdolls the targetted players for an optional amount of time.
Set time to 0 to unragdoll when the ragdoll stops moving.]])
