maestro.command("nolag", {}, function(caller)
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetClass() == "prop_physics" then
            local obj = ent:GetPhysicsObject()
            if IsValid(obj) then
                obj:EnableMotion(false)
            end
        end
    end
    return false, "froze all props"
end, [[
Freezes all props.]])
